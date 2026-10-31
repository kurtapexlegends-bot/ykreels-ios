import XCTest
@testable import ReelCore
@testable import ReelPlayer
@testable import ReelEngine

@MainActor
final class PlayerPoolCoordinatorTests: XCTestCase {
    var coordinator: PlayerPoolCoordinator!
    var sampleEpisodes: [Episode]!

    override func setUp() async throws {
        try await super.setUp()
        coordinator = PlayerPoolCoordinator()
        sampleEpisodes = WrongMatchRightCrushData.episodes
    }

    override func tearDown() async throws {
        coordinator.cleanupAllPlayers()
        coordinator = nil
        sampleEpisodes = nil
        try await super.tearDown()
    }

    func testLoadEpisodesAndRebuildPool() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)

        XCTAssertNotNil(coordinator.currentEpisode)
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 1)
        XCTAssertNotNil(coordinator.activePlayer)
        XCTAssertTrue(coordinator.isPlaying)
    }

    func testAdvanceAndRewindEpisodes() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 1)

        coordinator.advanceToNextEpisode()
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 2)

        coordinator.advanceToNextEpisode()
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 3)

        coordinator.returnToPreviousEpisode()
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 2)
    }

    func testBoundaryConditions() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        // Cannot rewind before index 0
        coordinator.returnToPreviousEpisode()
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, 1)

        // Advance to last episode
        let lastIndex = sampleEpisodes.count - 1
        coordinator.loadEpisodes(sampleEpisodes, startingAt: lastIndex)
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, sampleEpisodes.count)

        // Cannot advance past last episode
        coordinator.advanceToNextEpisode()
        XCTAssertEqual(coordinator.currentEpisode?.episodeNumber, sampleEpisodes.count)
    }

    func testPlaybackRateAndPause() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        coordinator.setPlaybackRate(1.5)
        XCTAssertEqual(coordinator.playbackRate, 1.5)

        coordinator.togglePlayPause()
        XCTAssertFalse(coordinator.isPlaying)

        coordinator.togglePlayPause()
        XCTAssertTrue(coordinator.isPlaying)
    }

    func testCleanupAllPlayers() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        XCTAssertNotNil(coordinator.activePlayer)

        coordinator.cleanupAllPlayers()
        XCTAssertNil(coordinator.activePlayer)
    }

    func testInitialSeek() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0, initialSeek: 30.0)
        XCTAssertEqual(coordinator.currentPlayhead, 30.0)
    }

    func testProgressReportingThrottled() {
        var reportedEpisode: Episode?
        var reportedPlayhead: Double = 0.0

        coordinator.onProgressUpdate = { ep, head, _ in
            reportedEpisode = ep
            reportedPlayhead = head
        }

        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        coordinator.seek(to: 42.0)

        XCTAssertEqual(reportedEpisode?.episodeNumber, 1)
        XCTAssertEqual(reportedPlayhead, 42.0)
    }

    func testDramaTitleHandling() {
        coordinator.loadEpisodes(sampleEpisodes, dramaTitle: "Custom Title", startingAt: 0)
        XCTAssertEqual(coordinator.currentDramaTitle, "Custom Title")
    }

    func testCoverURLAndBufferingState() {
        let testURL = URL(string: "https://example.com/cover.jpg")
        coordinator.loadEpisodes(sampleEpisodes, dramaTitle: "Test Cover", coverURL: testURL, startingAt: 0)
        XCTAssertEqual(coordinator.currentDramaCoverURL, testURL)
        XCTAssertTrue(coordinator.isBuffering)
        XCTAssertFalse(coordinator.hasRenderedFirstFrame)
    }

    func testExplicitPauseAndResume() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        XCTAssertTrue(coordinator.isPlaying)

        coordinator.pause()
        XCTAssertFalse(coordinator.isPlaying)

        coordinator.resume()
        XCTAssertTrue(coordinator.isPlaying)
    }

    func testMarkFirstFrameRendered() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        XCTAssertTrue(coordinator.isBuffering)
        XCTAssertFalse(coordinator.hasRenderedFirstFrame)

        coordinator.markFirstFrameRendered()
        XCTAssertFalse(coordinator.isBuffering)
        XCTAssertTrue(coordinator.hasRenderedFirstFrame)
    }

    func testAdjacentEpisodeNavigationFlags() {
        coordinator.loadEpisodes(sampleEpisodes, startingAt: 0)
        XCTAssertFalse(coordinator.hasPreviousEpisode)
        XCTAssertTrue(coordinator.hasNextEpisode)
        XCTAssertNil(coordinator.previousEpisode)
        XCTAssertEqual(coordinator.nextEpisode?.episodeNumber, 2)
        XCTAssertEqual(coordinator.currentEpisodeIndex, 0)

        coordinator.advanceToNextEpisode()
        XCTAssertTrue(coordinator.hasPreviousEpisode)
        XCTAssertEqual(coordinator.previousEpisode?.episodeNumber, 1)
        XCTAssertEqual(coordinator.currentEpisodeIndex, 1)
    }
}
