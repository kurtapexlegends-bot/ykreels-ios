import Foundation
import ReelCore
import ReelDatabase

/// Protocol defining the interface for drama discovery and episode loading.
public protocol DramaCatalogService: Sendable {
    func getFeaturedDrama() async throws -> Drama
    func getAllDramas() async throws -> [Drama]
    func getDrama(id: String) async throws -> Drama?
    func getEpisodes(dramaId: String) async throws -> [Episode]
    func getEpisode(dramaId: String, episodeNumber: Int) async throws -> Episode?
}

/// Dynamic, database-backed catalog service with pre-bundled fallback seed.
/// Provides zero-latency local startup and automatic remote updates.
public final class CuratedDramaCatalog: DramaCatalogService, @unchecked Sendable {
    public static let shared = CuratedDramaCatalog()

    private let fallbackDramas: [Drama]
    private let fallbackEpisodesMap: [String: [Episode]]

    public init() {
        self.fallbackDramas = CuratedCatalogData.allDramas
        var map: [String: [Episode]] = [:]
        for item in CuratedCatalogData.allCatalogItems {
            map[item.drama.id] = item.episodes
        }
        self.fallbackEpisodesMap = map

        // Seed initial items into SQLite if database is empty or outdated
        DramaRepository.shared.seedCatalogItemsIfNeeded(defaultCatalogItems)
    }

    /// Bundled starter items for offline readiness.
    public var defaultCatalogItems: [DramaCatalogItem] {
        CuratedCatalogData.allCatalogItems
    }

    public func getFeaturedDrama() async throws -> Drama {
        let all = try await getAllDramas()
        guard let drama = all.first else {
            throw ReelError.dramaNotFound("No featured drama available")
        }
        return drama
    }

    public func getAllDramas() async throws -> [Drama] {
        let local = (try? DramaRepository.shared.fetchAllDramas()) ?? []
        return local.isEmpty ? fallbackDramas : local
    }

    public func getDrama(id: String) async throws -> Drama? {
        if let local = try? DramaRepository.shared.fetchDrama(id: id) {
            return local
        }
        return fallbackDramas.first { $0.id == id }
    }

    public func getEpisodes(dramaId: String) async throws -> [Episode] {
        let local = (try? DramaRepository.shared.fetchEpisodes(dramaId: dramaId)) ?? []
        if !local.isEmpty {
            return local
        }
        return fallbackEpisodesMap[dramaId] ?? []
    }

    public func getEpisode(dramaId: String, episodeNumber: Int) async throws -> Episode? {
        let episodes = try await getEpisodes(dramaId: dramaId)
        return episodes.first { $0.episodeNumber == episodeNumber }
    }

    /// Triggers remote catalog synchronization.
    @discardableResult
    public func syncFromRemote(force: Bool = false) async -> CatalogSyncResult {
        await RemoteCatalogSyncService.shared.syncCatalog(force: force)
    }
}
