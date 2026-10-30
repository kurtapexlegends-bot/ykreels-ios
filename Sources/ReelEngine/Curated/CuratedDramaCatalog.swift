import Foundation
import ReelCore

/// Protocol defining the interface for drama discovery and episode loading.
public protocol DramaCatalogService: Sendable {
    func getFeaturedDrama() async throws -> Drama
    func getAllDramas() async throws -> [Drama]
    func getDrama(id: String) async throws -> Drama?
    func getEpisodes(dramaId: String) async throws -> [Episode]
    func getEpisode(dramaId: String, episodeNumber: Int) async throws -> Episode?
}

/// In-memory and local pre-bundled catalog service.
/// Provides zero-latency access to pre-seeded dramas without network round-trips.
public final class CuratedDramaCatalog: DramaCatalogService, @unchecked Sendable {
    public static let shared = CuratedDramaCatalog()

    private let dramas: [Drama]
    private let episodesMap: [String: [Episode]]

    public init() {
        self.dramas = [
            WrongMatchRightCrushData.drama,
            ExpandedCuratedDramasData.finalBossDrama,
            ExpandedCuratedDramasData.ceoContractWifeDrama,
            ExpandedCuratedDramasData.cursedAlphaDrama,
            ExpandedCuratedDramasData.fashionQueenDrama
        ]
        self.episodesMap = [
            WrongMatchRightCrushData.dramaId: WrongMatchRightCrushData.episodes,
            ExpandedCuratedDramasData.finalBossDrama.id: ExpandedCuratedDramasData.finalBossEpisodes,
            ExpandedCuratedDramasData.ceoContractWifeDrama.id: ExpandedCuratedDramasData.ceoContractWifeEpisodes,
            ExpandedCuratedDramasData.cursedAlphaDrama.id: ExpandedCuratedDramasData.cursedAlphaEpisodes,
            ExpandedCuratedDramasData.fashionQueenDrama.id: ExpandedCuratedDramasData.fashionQueenEpisodes
        ]
    }

    public func getFeaturedDrama() async throws -> Drama {
        guard let drama = dramas.first else {
            throw ReelError.dramaNotFound("No featured drama available")
        }
        return drama
    }

    public func getAllDramas() async throws -> [Drama] {
        dramas
    }

    public func getDrama(id: String) async throws -> Drama? {
        dramas.first { $0.id == id }
    }

    public func getEpisodes(dramaId: String) async throws -> [Episode] {
        episodesMap[dramaId] ?? []
    }

    public func getEpisode(dramaId: String, episodeNumber: Int) async throws -> Episode? {
        guard let episodes = episodesMap[dramaId] else { return nil }
        return episodes.first { $0.episodeNumber == episodeNumber }
    }
}
