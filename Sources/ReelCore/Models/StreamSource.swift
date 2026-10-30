import Foundation

/// Media format of an episode stream.
public enum StreamFormat: String, Codable, Sendable {
    case hls = "hls"
    case mp4 = "mp4"
}

/// Video quality profile for an episode stream.
public enum StreamQuality: String, Codable, Sendable, Comparable {
    case sd480p = "480p"
    case hd720p = "720p"
    case fhd1080p = "1080p"
    case auto = "auto"

    private var sortOrder: Int {
        switch self {
        case .sd480p: return 1
        case .hd720p: return 2
        case .fhd1080p: return 3
        case .auto: return 4
        }
    }

    public static func < (lhs: StreamQuality, rhs: StreamQuality) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

/// Subtitle track definition.
public struct SubtitleTrack: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let languageCode: String
    public let languageName: String
    public let url: URL
    public let isDefault: Bool

    public init(
        id: String,
        languageCode: String,
        languageName: String,
        url: URL,
        isDefault: Bool = false
    ) {
        self.id = id
        self.languageCode = languageCode
        self.languageName = languageName
        self.url = url
        self.isDefault = isDefault
    }
}

/// A playable media source for an episode.
public struct StreamSource: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let url: URL
    public let format: StreamFormat
    public let quality: StreamQuality
    public let isDefault: Bool

    public init(
        id: String = UUID().uuidString,
        url: URL,
        format: StreamFormat,
        quality: StreamQuality = .fhd1080p,
        isDefault: Bool = false
    ) {
        self.id = id
        self.url = url
        self.format = format
        self.quality = quality
        self.isDefault = isDefault
    }
}
