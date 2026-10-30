import XCTest
import GRDB
@testable import ReelCore
@testable import ReelDatabase

final class DramaRepositoryTests: XCTestCase {
    var database: AppDatabase!
    var repository: DramaRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        database = try AppDatabase.makeInMemory()
        repository = DramaRepository(database: database)
    }

    override func tearDownWithError() throws {
        database = nil
        repository = nil
        try super.tearDownWithError()
    }

    func testUpsertAndFetchDrama() throws {
        let drama = Drama(
            id: "test-drama",
            title: "Test Drama Title",
            synopsis: "A test drama synopsis for database verification.",
            genres: ["Romance", "Drama"],
            tags: ["Campus"],
            totalEpisodes: 25,
            releaseYear: 2024,
            cast: ["Actor A", "Actor B"]
        )

        try repository.upsertDrama(drama)
        let fetched = try repository.fetchDrama(id: "test-drama")

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, "test-drama")
        XCTAssertEqual(fetched?.title, "Test Drama Title")
        XCTAssertEqual(fetched?.totalEpisodes, 25)
        XCTAssertEqual(fetched?.genres, ["Romance", "Drama"])
        XCTAssertEqual(fetched?.cast, ["Actor A", "Actor B"])
        XCTAssertFalse(fetched?.isBookmarked ?? true)
    }

    func testToggleBookmark() throws {
        let drama = Drama(
            id: "test-drama-bm",
            title: "Bookmark Test",
            synopsis: "Synopsis",
            genres: ["Romance"],
            totalEpisodes: 10
        )
        try repository.upsertDrama(drama)

        let isBookmarked1 = try repository.toggleBookmark(dramaId: "test-drama-bm")
        XCTAssertTrue(isBookmarked1)

        let isBookmarked2 = try repository.toggleBookmark(dramaId: "test-drama-bm")
        XCTAssertFalse(isBookmarked2)
    }

    func testEpisodeOperations() throws {
        let drama = Drama(
            id: "drama-ep-test",
            title: "Episode Test Drama",
            synopsis: "Synopsis",
            genres: ["Drama"],
            totalEpisodes: 2
        )
        try repository.upsertDrama(drama)

        let ep1 = Episode(
            id: "ep-01",
            dramaId: "drama-ep-test",
            episodeNumber: 1,
            title: "The Pilot",
            synopsis: "Opening scene",
            durationSeconds: 100,
            streamSources: []
        )
        let ep2 = Episode(
            id: "ep-02",
            dramaId: "drama-ep-test",
            episodeNumber: 2,
            title: "The Conflict",
            synopsis: "Rising tension",
            durationSeconds: 110,
            streamSources: []
        )

        try repository.upsertEpisodes([ep1, ep2])

        let episodes = try repository.fetchEpisodes(dramaId: "drama-ep-test")
        XCTAssertEqual(episodes.count, 2)
        XCTAssertEqual(episodes[0].title, "The Pilot")
        XCTAssertEqual(episodes[1].title, "The Conflict")

        // Update download state
        try repository.updateDownloadState(episodeId: "ep-01", downloadState: .downloaded(localPath: "/tmp/ep1.mp4"))
        let updatedEp = try repository.fetchEpisode(id: "ep-01")
        XCTAssertTrue(updatedEp?.downloadState.isDownloaded == true)
    }

    func testPlaybackProgressAndWatchHistory() throws {
        let drama = Drama(
            id: "drama-progress",
            title: "Progress Drama",
            synopsis: "Synopsis",
            genres: ["Romance"],
            totalEpisodes: 5
        )
        try repository.upsertDrama(drama)

        let ep = Episode(
            id: "ep-prog-1",
            dramaId: "drama-progress",
            episodeNumber: 1,
            title: "Episode 1",
            durationSeconds: 100,
            streamSources: []
        )
        try repository.upsertEpisode(ep)

        let progress = PlaybackProgress(
            dramaId: "drama-progress",
            lastEpisodeId: "ep-prog-1",
            lastEpisodeNumber: 1,
            playheadSeconds: 45.0,
            durationSeconds: 100.0
        )
        try repository.upsertPlaybackProgress(progress)

        let fetchedProgress = try repository.fetchPlaybackProgress(dramaId: "drama-progress")
        guard let fetched = fetchedProgress else {
            XCTFail("Expected fetched progress to not be nil")
            return
        }
        XCTAssertEqual(fetched.playheadSeconds, 45.0)
        XCTAssertEqual(fetched.progressRatio, 0.45, accuracy: 0.001)

        let history = WatchHistory(
            id: "hist-1",
            dramaId: "drama-progress",
            episodeId: "ep-prog-1",
            episodeNumber: 1
        )
        try repository.recordWatchHistory(history)

        let historyList = try repository.fetchWatchHistory(limit: 10)
        XCTAssertEqual(historyList.count, 1)
        XCTAssertEqual(historyList.first?.episodeId, "ep-prog-1")
    }

    func testSearchDramasWithFTS5() throws {
        let drama1 = Drama(
            id: "d1",
            title: "Wrong Match, Right Crush",
            synopsis: "College freshman Nora mistakenly texts Beckett.",
            genres: ["Romance"],
            totalEpisodes: 25,
            cast: ["Nora", "Theo", "Beckett"]
        )
        let drama2 = Drama(
            id: "d2",
            title: "Billionaire Heir Revenge",
            synopsis: "Corporate courtroom rivalry and drama.",
            genres: ["Suspense"],
            totalEpisodes: 30,
            cast: ["Marcus", "Elena"]
        )
        try repository.upsertDrama(drama1)
        try repository.upsertDrama(drama2)

        let searchByTitle = try repository.searchDramas(query: "Wrong")
        XCTAssertEqual(searchByTitle.count, 1)
        XCTAssertEqual(searchByTitle.first?.id, "d1")

        let searchByCharacter = try repository.searchDramas(query: "Marcus")
        XCTAssertEqual(searchByCharacter.count, 1)
        XCTAssertEqual(searchByCharacter.first?.id, "d2")

        let searchWithSpecialChars = try repository.searchDramas(query: "Wrong - Match (Lead)")
        XCTAssertFalse(searchWithSpecialChars.isEmpty)
    }

    func testSeedCuratedDramasIfNeeded() throws {
        let drama = Drama(
            id: "seed-drama",
            title: "Seed Drama",
            synopsis: "Synopsis",
            genres: ["Romance"],
            totalEpisodes: 1
        )
        let ep = Episode(
            id: "seed-ep-1",
            dramaId: "seed-drama",
            episodeNumber: 1,
            title: "Seed Ep",
            durationSeconds: 90,
            streamSources: []
        )
        repository.seedCuratedDramasIfNeeded(drama: drama, episodes: [ep])

        let fetchedDrama = try repository.fetchDrama(id: "seed-drama")
        XCTAssertNotNil(fetchedDrama)
        let fetchedEps = try repository.fetchEpisodes(dramaId: "seed-drama")
        XCTAssertEqual(fetchedEps.count, 1)

        // Seed again should be idempotent without error
        repository.seedCuratedDramasIfNeeded(drama: drama, episodes: [ep])
        let reFetchedEps = try repository.fetchEpisodes(dramaId: "seed-drama")
        XCTAssertEqual(reFetchedEps.count, 1)
    }

    func testDownloadStateExplicitCodableRoundtrip() throws {
        let states: [DownloadState] = [
            .notDownloaded,
            .downloading(progress: 0.45),
            .downloaded(localPath: "/var/mobile/ep1.mp4"),
            .failed(error: "Network timeout")
        ]

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for state in states {
            let data = try encoder.encode(state)
            let decoded = try decoder.decode(DownloadState.self, from: data)
            XCTAssertEqual(state, decoded)
        }

        // Test decoding plain string representation from migration default
        let plainStringData = Data("\"notDownloaded\"".utf8)
        let decodedPlain = try decoder.decode(DownloadState.self, from: plainStringData)
        XCTAssertEqual(decodedPlain, .notDownloaded)
    }
}
