import XCTest
@testable import ReelCore
@testable import ReelDownload

final class EpisodeDownloadManagerTests: XCTestCase {
    var manager: EpisodeDownloadManager!

    override func setUp() {
        super.setUp()
        manager = EpisodeDownloadManager.shared
    }

    override func tearDown() {
        try? manager.clearAllCache()
        super.tearDown()
    }

    func testLocalFileURLGeneration() {
        let fileURL = manager.localFileURL(for: "ep-test-01")
        XCTAssertTrue(fileURL.path.contains("EpisodeDownloads"))
        XCTAssertTrue(fileURL.lastPathComponent == "ep-test-01.mp4")
    }

    func testCalculateCacheSizeAndClear() throws {
        // Clear all initial cache
        try manager.clearAllCache()
        let size = manager.calculateTotalCacheSize()
        XCTAssertEqual(size, 0)
        XCTAssertEqual(manager.calculateTotalCacheSizeMB(), 0.0)

        // Write a small dummy file to test size calculation
        let testURL = manager.localFileURL(for: "dummy-test-ep")
        let dummyData = Data(repeating: 0x41, count: 1024 * 1024) // 1MB
        try dummyData.write(to: testURL)

        XCTAssertTrue(manager.isEpisodeDownloaded(episodeId: "dummy-test-ep"))
        let newSize = manager.calculateTotalCacheSize()
        XCTAssertGreaterThanOrEqual(newSize, 1024 * 1024)

        // Clear cache and verify removal
        try manager.clearAllCache()
        XCTAssertFalse(manager.isEpisodeDownloaded(episodeId: "dummy-test-ep"))
        XCTAssertEqual(manager.calculateTotalCacheSize(), 0)
    }

    func testDeleteSpecificDownloadedEpisode() throws {
        let testURL = manager.localFileURL(for: "specific-ep")
        try Data("test".utf8).write(to: testURL)
        XCTAssertTrue(manager.isEpisodeDownloaded(episodeId: "specific-ep"))

        try manager.deleteDownloadedEpisode(episodeId: "specific-ep")
        XCTAssertFalse(manager.isEpisodeDownloaded(episodeId: "specific-ep"))
    }

    func testPurgeOldestChunksUnderLimit() {
        // Purging when under limit does not delete files
        let testURL = manager.localFileURL(for: "keep-ep")
        try? Data("keep".utf8).write(to: testURL)
        manager.purgeOldestChunksIfNeeded()
        XCTAssertTrue(manager.isEpisodeDownloaded(episodeId: "keep-ep"))
    }
}
