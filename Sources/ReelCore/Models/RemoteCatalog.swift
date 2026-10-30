import Foundation

/// Remote manifest payload fetched from CDN or GitHub Raw.
public struct RemoteCatalogPayload: Codable, Sendable {
    public let version: Int
    public let updatedAt: Date?
    public let featuredDramaId: String?
    public let items: [DramaCatalogItem]

    public init(
        version: Int,
        updatedAt: Date? = nil,
        featuredDramaId: String? = nil,
        items: [DramaCatalogItem]
    ) {
        self.version = version
        self.updatedAt = updatedAt
        self.featuredDramaId = featuredDramaId
        self.items = items
    }
}

/// A drama paired with its full list of episodes in the catalog.
public struct DramaCatalogItem: Codable, Sendable, Identifiable {
    public var id: String { drama.id }
    public let drama: Drama
    public let episodes: [Episode]

    public init(drama: Drama, episodes: [Episode]) {
        self.drama = drama
        self.episodes = episodes
    }
}
