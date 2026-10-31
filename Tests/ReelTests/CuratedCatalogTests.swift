import XCTest
@testable import ReelCore
@testable import ReelEngine

final class CuratedCatalogTests: XCTestCase {
    func testFeaturedDramaMetadata() async throws {
        let catalog = CuratedDramaCatalog.shared
        let drama = try await catalog.getFeaturedDrama()

        XCTAssertEqual(drama.id, "taming-my-bullies")
        XCTAssertEqual(drama.title, "Taming My Bullies")
        XCTAssertEqual(drama.totalEpisodes, 7)
        XCTAssertTrue(drama.genres.contains("Romance"))
        XCTAssertTrue(drama.cast.contains(where: { $0.contains("Emma") }))
        XCTAssertTrue(drama.cast.contains(where: { $0.contains("Rowan") }))
    }

    func testFeaturedDramaEpisodesCountAndIntegrity() async throws {
        let catalog = CuratedDramaCatalog.shared
        let episodes = try await catalog.getEpisodes(dramaId: "taming-my-bullies")

        XCTAssertEqual(episodes.count, 7, "Must contain all 7 episodes")
        
        // Check first episode
        let ep1 = episodes.first(where: { $0.episodeNumber == 1 })
        XCTAssertNotNil(ep1)
        XCTAssertEqual(ep1?.title, "Emma Meets Rowan")
        XCTAssertTrue(ep1?.isUnlocked == true, "Every episode must be 100% free and unlocked")
        XCTAssertNotNil(ep1?.primaryStreamURL)

        // Check finale episode
        let ep7 = episodes.first(where: { $0.episodeNumber == 7 })
        XCTAssertNotNil(ep7)
        XCTAssertEqual(ep7?.title, "High School Queen Feature")
        XCTAssertEqual(ep7?.episodeNumber, 7)
        XCTAssertTrue(ep7?.isUnlocked == true)
    }

    func testEpisodeFormatting() {
        let ep = Episode(
            id: "test",
            dramaId: "test-drama",
            episodeNumber: 1,
            title: "Test",
            durationSeconds: 105,
            streamSources: []
        )
        XCTAssertEqual(ep.formattedDuration, "1m 45s")
    }

    func testPlaybackProgressCalculation() {
        let progress = PlaybackProgress(
            dramaId: "test-drama",
            lastEpisodeId: "ep-1",
            lastEpisodeNumber: 1,
            playheadSeconds: 60,
            durationSeconds: 120
        )
        XCTAssertEqual(progress.progressRatio, 0.5, accuracy: 0.001)
        XCTAssertEqual(progress.percentageString, "50%")
    }

    func testThemeTokensAndColors() {
        // Verify Sakura Pink accent presence
        XCTAssertNotNil(ReelTheme.sakuraPink)
        XCTAssertNotNil(ReelTheme.sakuraMist)
        XCTAssertNotNil(ReelTheme.sakuraGlow)
        XCTAssertEqual(ReelTheme.verticalReelAspectRatio, 9.0 / 16.0)
    }

    func testAllCuratedDramasCountAndIntegrity() async throws {
        let catalog = CuratedDramaCatalog.shared
        let allDramas = try await catalog.getAllDramas()

        XCTAssertEqual(allDramas.count, 12, "Must contain all 12 curated English drama series")

        var grandTotalEpisodes = 0
        for drama in allDramas {
            let episodes = try await catalog.getEpisodes(dramaId: drama.id)
            XCTAssertGreaterThanOrEqual(episodes.count, 1, "Drama \(drama.title) must have at least 1 episode")
            XCTAssertTrue(episodes.allSatisfy { $0.isUnlocked }, "All episodes in \(drama.title) must be 100% unlocked")
            XCTAssertTrue(episodes.allSatisfy { $0.primaryStreamURL != nil }, "All episodes must have a valid stream source")
            grandTotalEpisodes += episodes.count
        }

        XCTAssertEqual(grandTotalEpisodes, 38, "Total across all 12 series must match curated episode count")
    }
}
