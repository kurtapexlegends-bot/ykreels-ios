import XCTest
import Foundation
@testable import ReelCore
@testable import ReelDatabase
@testable import ReelEngine

final class RemoteCatalogSyncTests: XCTestCase {

    func testRemoteCatalogPayloadDecoding() throws {
        let json = """
        {
            "version": 1,
            "updatedAt": "2026-10-31T02:00:00Z",
            "featuredDramaId": "drama-test-1",
            "items": [
                {
                    "drama": {
                        "id": "drama-test-1",
                        "title": "Test Drama",
                        "synopsis": "Test synopsis",
                        "genres": ["Romance"],
                        "tags": ["Fake Dating"],
                        "totalEpisodes": 2,
                        "releaseYear": 2024,
                        "cast": ["Actor A", "Actor B"],
                        "isBookmarked": false,
                        "createdAt": "2026-10-31T02:00:00Z",
                        "updatedAt": "2026-10-31T02:00:00Z"
                    },
                    "episodes": [
                        {
                            "id": "ep-test-1-01",
                            "dramaId": "drama-test-1",
                            "episodeNumber": 1,
                            "title": "Episode 1",
                            "durationSeconds": 90.0,
                            "streamSources": [],
                            "subtitles": [],
                            "isUnlocked": true,
                            "downloadState": "notDownloaded"
                        },
                        {
                            "id": "ep-test-1-02",
                            "dramaId": "drama-test-1",
                            "episodeNumber": 2,
                            "title": "Episode 2",
                            "durationSeconds": 95.0,
                            "streamSources": [],
                            "subtitles": [],
                            "isUnlocked": true,
                            "downloadState": "notDownloaded"
                        }
                    ]
                }
            ]
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(RemoteCatalogPayload.self, from: Data(json.utf8))

        XCTAssertEqual(payload.version, 1)
        XCTAssertEqual(payload.featuredDramaId, "drama-test-1")
        XCTAssertEqual(payload.items.count, 1)

        let item = payload.items[0]
        XCTAssertEqual(item.drama.title, "Test Drama")
        XCTAssertEqual(item.episodes.count, 2)
        XCTAssertEqual(item.episodes[0].title, "Episode 1")
    }

    func testBatchUpsertCatalogItemsInDatabase() throws {
        let repo = DramaRepository.shared

        let drama = Drama(
            id: "drama-batch-test",
            title: "Batch Test Drama",
            synopsis: "Testing batch upsert",
            genres: ["Drama"],
            totalEpisodes: 2
        )

        let ep1 = Episode(
            id: "ep-batch-01",
            dramaId: drama.id,
            episodeNumber: 1,
            title: "Batch Ep 1",
            durationSeconds: 90,
            streamSources: []
        )
        let ep2 = Episode(
            id: "ep-batch-02",
            dramaId: drama.id,
            episodeNumber: 2,
            title: "Batch Ep 2",
            durationSeconds: 95,
            streamSources: []
        )

        let item = DramaCatalogItem(drama: drama, episodes: [ep1, ep2])

        let expectation = expectation(description: "Notification posted")
        let observer = NotificationCenter.default.addObserver(
            forName: .dramaCatalogDidUpdate,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        try repo.upsertCatalogItems([item])

        wait(for: [expectation], timeout: 2.0)
        NotificationCenter.default.removeObserver(observer)

        let fetchedDrama = try repo.fetchDrama(id: drama.id)
        XCTAssertNotNil(fetchedDrama)
        XCTAssertEqual(fetchedDrama?.title, "Batch Test Drama")

        let fetchedEpisodes = try repo.fetchEpisodes(dramaId: drama.id)
        XCTAssertEqual(fetchedEpisodes.count, 2)
    }

    func testSyncServiceCustomURLSetting() async {
        let service = RemoteCatalogSyncService.shared
        let customURL = "https://example.com/custom_catalog.json"

        await service.setCustomFeedURL(customURL)
        let activeURL = await service.activeFeedURL
        XCTAssertEqual(activeURL.absoluteString, customURL)

        await service.setCustomFeedURL(nil)
        let revertedURL = await service.activeFeedURL
        XCTAssertEqual(revertedURL, RemoteCatalogSyncService.defaultFeedURL)
    }
}
