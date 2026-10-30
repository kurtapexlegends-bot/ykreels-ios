import Foundation

/// Saved playhead position and progress for a drama series.
public struct PlaybackProgress: Identifiable, Hashable, Codable, Sendable {
    public var id: String { dramaId }
    public let dramaId: String
    public let lastEpisodeId: String
    public let lastEpisodeNumber: Int
    public let playheadSeconds: Double
    public let durationSeconds: Double
    public let updatedAt: Date
    public let isCompleted: Bool

    public init(
        dramaId: String,
        lastEpisodeId: String,
        lastEpisodeNumber: Int,
        playheadSeconds: Double,
        durationSeconds: Double,
        updatedAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.dramaId = dramaId
        self.lastEpisodeId = lastEpisodeId
        self.lastEpisodeNumber = lastEpisodeNumber
        self.playheadSeconds = playheadSeconds
        self.durationSeconds = durationSeconds
        self.updatedAt = updatedAt
        self.isCompleted = isCompleted
    }

    /// Progress ratio between 0.0 and 1.0.
    public var progressRatio: Double {
        guard durationSeconds > 0 else { return 0.0 }
        return min(max(playheadSeconds / durationSeconds, 0.0), 1.0)
    }

    /// Progress formatted as percentage (e.g. 75%).
    public var percentageString: String {
        "\(Int(progressRatio * 100))%"
    }
}

/// Historical log entry for a watched episode.
public struct WatchHistory: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let dramaId: String
    public let episodeId: String
    public let episodeNumber: Int
    public let watchedAt: Date

    public init(
        id: String = UUID().uuidString,
        dramaId: String,
        episodeId: String,
        episodeNumber: Int,
        watchedAt: Date = Date()
    ) {
        self.id = id
        self.dramaId = dramaId
        self.episodeId = episodeId
        self.episodeNumber = episodeNumber
        self.watchedAt = watchedAt
    }
}
