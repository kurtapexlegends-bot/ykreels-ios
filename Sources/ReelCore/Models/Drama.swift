import Foundation

/// A complete short-drama series containing multiple vertical episodes.
public struct Drama: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let synopsis: String
    public let coverURL: URL?
    public let bannerURL: URL?
    public let genres: [String]
    public let tags: [String]
    public let totalEpisodes: Int
    public let releaseYear: Int
    public let cast: [String]
    public var isBookmarked: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: String,
        title: String,
        synopsis: String,
        coverURL: URL? = nil,
        bannerURL: URL? = nil,
        genres: [String],
        tags: [String] = [],
        totalEpisodes: Int,
        releaseYear: Int = 2024,
        cast: [String] = [],
        isBookmarked: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.coverURL = coverURL
        self.bannerURL = bannerURL
        self.genres = genres
        self.tags = tags
        self.totalEpisodes = totalEpisodes
        self.releaseYear = releaseYear
        self.cast = cast
        self.isBookmarked = isBookmarked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Formatted comma-separated genres string.
    public var genresDisplay: String {
        genres.joined(separator: " • ")
    }
}
