import Foundation
import ReelCore

/// Background URLSession download manager and smart 250MB LRU disk cache manager.
/// Ensures episode video storage never bloats device capacity.
public final class EpisodeDownloadManager: NSObject, Sendable {
    public static let shared = EpisodeDownloadManager()

    public static let maxCacheSizeBytes: Int64 = 250 * 1024 * 1024 // 250MB
    private let downloadsDirectory: URL

    public override init() {
        let fileManager = FileManager.default
        let appSupport = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.temporaryDirectory

        self.downloadsDirectory = appSupport.appendingPathComponent("EpisodeDownloads", isDirectory: true)
        try? fileManager.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)
        super.init()
    }

    /// Destination file URL for an episode.
    public func localFileURL(for episodeId: String) -> URL {
        downloadsDirectory.appendingPathComponent("\(episodeId).mp4")
    }

    /// Checks if an episode has been cached locally on disk.
    public func isEpisodeDownloaded(episodeId: String) -> Bool {
        let fileURL = localFileURL(for: episodeId)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// Downloads an episode stream to disk and enforces LRU cache limits.
    public func downloadEpisode(_ episode: Episode) async throws -> URL {
        let downloadURL = episode.streamSources.first(where: { $0.format == .mp4 })?.url ?? episode.primaryStreamURL
        guard let remoteURL = downloadURL else {
            throw ReelError.streamUnavailable("No valid stream URL for episode \(episode.id)")
        }

        let destination = localFileURL(for: episode.id)
        if FileManager.default.fileExists(atPath: destination.path) {
            return destination
        }

        let (tempURL, _) = try await URLSession.shared.download(from: remoteURL)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.moveItem(at: tempURL, to: destination)
        purgeOldestChunksIfNeeded()
        return destination
    }

    /// Deletes a specific local offline episode file.
    public func deleteDownloadedEpisode(episodeId: String) throws {
        let fileURL = localFileURL(for: episodeId)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    /// Flushes all cached video files from disk.
    public func clearAllCache() throws {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: downloadsDirectory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return }
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }

    /// Computes total size of current cached video files in bytes.
    public func calculateTotalCacheSize() -> Int64 {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: downloadsDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        return files.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }

    /// Computes total size in megabytes.
    public func calculateTotalCacheSizeMB() -> Double {
        Double(calculateTotalCacheSize()) / (1024.0 * 1024.0)
    }

    /// Enforces the 250MB LRU eviction policy by deleting the oldest accessed files.
    public func purgeOldestChunksIfNeeded() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: downloadsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        var currentSize = calculateTotalCacheSize()
        guard currentSize > Self.maxCacheSizeBytes else { return }

        let sortedFiles = files.sorted {
            let date1 = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            let date2 = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            return date1 < date2
        }

        for file in sortedFiles {
            guard currentSize > Self.maxCacheSizeBytes else { break }
            let fileSize = Int64((try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
            try? fileManager.removeItem(at: file)
            currentSize -= fileSize
        }
    }
}
