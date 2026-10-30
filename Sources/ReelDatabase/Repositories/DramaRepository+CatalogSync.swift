import Foundation
import GRDB
import ReelCore

extension Notification.Name {
    /// Notification posted whenever new or updated dramas/episodes are synced into SQLite.
    public static let dramaCatalogDidUpdate = Notification.Name("ReelDramaCatalogDidUpdate")
}

extension DramaRepository {

    /// Atomically upserts an array of dramas and their full episode sets in a single SQLite transaction.
    /// Posts `.dramaCatalogDidUpdate` upon successful commit.
    public func upsertCatalogItems(_ items: [DramaCatalogItem]) throws {
        guard !items.isEmpty else { return }

        try database.writer.write { db in
            for item in items {
                try self.executeUpsertDrama(db, drama: item.drama)
                for episode in item.episodes {
                    try self.executeUpsertEpisode(db, episode: episode)
                }
            }
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .dramaCatalogDidUpdate, object: nil)
        }
    }

    /// Seeds curated catalog items into the local SQLite database if the dramas table is currently empty.
    public func seedCatalogItemsIfNeeded(_ items: [DramaCatalogItem]) {
        do {
            let count = try fetchTotalDramaCount()
            if count == 0 {
                try upsertCatalogItems(items)
            }
        } catch {
            // Keep resilient if database is locked or migrating
        }
    }

    /// Fetches the total number of drama series stored locally in SQLite.
    public func fetchTotalDramaCount() throws -> Int {
        try database.reader.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM dramas") ?? 0
        }
    }

    /// Fetches the total number of episodes stored locally in SQLite.
    public func fetchTotalEpisodeCount() throws -> Int {
        try database.reader.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM episodes") ?? 0
        }
    }

    /// Fetches all dramas and their corresponding episodes as coupled catalog items.
    public func fetchAllCatalogItems() throws -> [DramaCatalogItem] {
        let dramas = try fetchAllDramas()
        return try dramas.map { drama in
            let episodes = try fetchEpisodes(dramaId: drama.id)
            return DramaCatalogItem(drama: drama, episodes: episodes)
        }
    }
}
