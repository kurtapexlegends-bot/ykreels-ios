import Foundation

/// State of an episode's offline availability.
public enum DownloadState: Hashable, Codable, Sendable {
    case notDownloaded
    case downloading(progress: Double)
    case downloaded(localPath: String)
    case failed(error: String)

    public var isDownloaded: Bool {
        if case .downloaded = self { return true }
        return false
    }

    public var isDownloading: Bool {
        if case .downloading = self { return true }
        return false
    }

    private enum CodingKeys: String, CodingKey {
        case type, progress, localPath, error
    }

    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let str = try? single.decode(String.self), str == "notDownloaded" {
            self = .notDownloaded
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = (try? container.decode(String.self, forKey: .type)) ?? "notDownloaded"
        switch type {
        case "downloading":
            let progress = (try? container.decode(Double.self, forKey: .progress)) ?? 0.0
            self = .downloading(progress: progress)
        case "downloaded":
            let path = (try? container.decode(String.self, forKey: .localPath)) ?? ""
            self = .downloaded(localPath: path)
        case "failed":
            let error = (try? container.decode(String.self, forKey: .error)) ?? "Unknown error"
            self = .failed(error: error)
        default:
            self = .notDownloaded
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .notDownloaded:
            var container = encoder.singleValueContainer()
            try container.encode("notDownloaded")
        case .downloading(let progress):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("downloading", forKey: .type)
            try container.encode(progress, forKey: .progress)
        case .downloaded(let path):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("downloaded", forKey: .type)
            try container.encode(path, forKey: .localPath)
        case .failed(let error):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("failed", forKey: .type)
            try container.encode(error, forKey: .error)
        }
    }
}

/// A single short-drama episode (typically 90-120 seconds in 9:16 vertical orientation).
public struct Episode: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let dramaId: String
    public let episodeNumber: Int
    public let title: String
    public let synopsis: String?
    public let durationSeconds: Double
    public let thumbnailURL: URL?
    public let streamSources: [StreamSource]
    public let subtitles: [SubtitleTrack]
    public let isUnlocked: Bool
    public var downloadState: DownloadState

    public init(
        id: String,
        dramaId: String,
        episodeNumber: Int,
        title: String,
        synopsis: String? = nil,
        durationSeconds: Double,
        thumbnailURL: URL? = nil,
        streamSources: [StreamSource],
        subtitles: [SubtitleTrack] = [],
        isUnlocked: Bool = true,
        downloadState: DownloadState = .notDownloaded
    ) {
        self.id = id
        self.dramaId = dramaId
        self.episodeNumber = episodeNumber
        self.title = title
        self.synopsis = synopsis
        self.durationSeconds = durationSeconds
        self.thumbnailURL = thumbnailURL
        self.streamSources = streamSources
        self.subtitles = subtitles
        self.isUnlocked = isUnlocked
        self.downloadState = downloadState
    }

    /// Primary stream source URL to play by default.
    public var primaryStreamURL: URL? {
        if case .downloaded(let localPath) = downloadState {
            return URL(fileURLWithPath: localPath)
        }
        return streamSources.first(where: { $0.isDefault })?.url ?? streamSources.first?.url
    }

    /// Formatted runtime string (e.g., "1m 45s").
    public var formattedDuration: String {
        let totalSeconds = Int(durationSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}
