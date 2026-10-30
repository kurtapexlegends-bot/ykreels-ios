import XCTest
@testable import ReelCore
@testable import ReelEngine

final class CuratedCatalogTests: XCTestCase {
    func testWrongMatchRightCrushMetadata() async throws {
        let catalog = CuratedDramaCatalog.shared
        let drama = try await catalog.getFeaturedDrama()

        XCTAssertEqual(drama.id, "drama-wrong-match-right-crush")
        XCTAssertEqual(drama.title, "Wrong Match, Right Crush")
        XCTAssertEqual(drama.totalEpisodes, 25)
        XCTAssertTrue(drama.genres.contains("Romance"))
        XCTAssertTrue(drama.cast.contains(where: { $0.contains("Nora") }))
        XCTAssertTrue(drama.cast.contains(where: { $0.contains("Theo") }))
    }

    func testWrongMatchRightCrushEpisodesCountAndIntegrity() async throws {
        let catalog = CuratedDramaCatalog.shared
        let episodes = try await catalog.getEpisodes(dramaId: "drama-wrong-match-right-crush")

        XCTAssertEqual(episodes.count, 25, "Must contain all 25 episodes")
        
        // Check first episode
        let ep1 = episodes.first(where: { $0.episodeNumber == 1 })
        XCTAssertNotNil(ep1)
        XCTAssertEqual(ep1?.title, "The Wrong Number")
        XCTAssertTrue(ep1?.isUnlocked == true, "Every episode must be 100% free and unlocked")
        XCTAssertNotNil(ep1?.primaryStreamURL)

        // Check finale episode
        let ep25 = episodes.first(where: { $0.episodeNumber == 25 })
        XCTAssertNotNil(ep25)
        XCTAssertEqual(ep25?.title, "Right Match, Right Here")
        XCTAssertEqual(ep25?.episodeNumber, 25)
        XCTAssertTrue(ep25?.isUnlocked == true)
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

    func testAllExpandedDramasCountAndIntegrity() async throws {
        let catalog = CuratedDramaCatalog.shared
        let allDramas = try await catalog.getAllDramas()

        XCTAssertEqual(allDramas.count, 5, "Must contain all 5 curated drama series")

        let expectedCounts = [
            "drama-wrong-match-right-crush": 25,
            "drama-final-boss": 30,
            "drama-ceo-contract-wife": 28,
            "drama-cursed-alpha": 26,
            "drama-fashion-queen": 24
        ]

        var grandTotalEpisodes = 0
        for drama in allDramas {
            let episodes = try await catalog.getEpisodes(dramaId: drama.id)
            let expected = expectedCounts[drama.id]
            XCTAssertEqual(episodes.count, expected, "Mismatch for \(drama.title)")
            XCTAssertTrue(episodes.allSatisfy { $0.isUnlocked }, "All episodes in \(drama.title) must be 100% unlocked")
            grandTotalEpisodes += episodes.count
        }

        XCTAssertEqual(grandTotalEpisodes, 133, "Grand total across all 5 series must be 133 episodes")
    }
}
