import Foundation
import GRDB
import ReelCore

public enum SchemaMigrations {
    /// Registers all database schema migrations in chronological order.
    public static func registerMigrations(in migrator: inout DatabaseMigrator) {
        
        // MARK: - v1: Initial Core Schema
        migrator.registerMigration("v1_initial_schema") { db in
            // Dramas table
            try db.create(table: "dramas") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull().indexed()
                t.column("synopsis", .text).notNull()
                t.column("cover_url", .text)
                t.column("banner_url", .text)
                t.column("genres", .text).notNull().defaults(to: "[]")
                t.column("tags", .text).notNull().defaults(to: "[]")
                t.column("total_episodes", .integer).notNull().defaults(to: 0)
                t.column("release_year", .integer).notNull().defaults(to: 2024)
                t.column("cast", .text).notNull().defaults(to: "[]")
                t.column("is_bookmarked", .boolean).notNull().defaults(to: false).indexed()
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
            }

            // Episodes table
            try db.create(table: "episodes") { t in
                t.column("id", .text).primaryKey()
                t.column("drama_id", .text).notNull().references("dramas", onDelete: .cascade).indexed()
                t.column("episode_number", .integer).notNull().indexed()
                t.column("title", .text).notNull()
                t.column("synopsis", .text)
                t.column("duration_seconds", .double).notNull().defaults(to: 0.0)
                t.column("thumbnail_url", .text)
                t.column("stream_sources_json", .text).notNull().defaults(to: "[]")
                t.column("subtitles_json", .text).notNull().defaults(to: "[]")
                t.column("is_unlocked", .boolean).notNull().defaults(to: true)
                t.column("download_state_json", .text).notNull().defaults(to: "\"notDownloaded\"")
                t.uniqueKey(["drama_id", "episode_number"])
            }

            // Playback Progress table (One record per drama)
            try db.create(table: "playback_progress") { t in
                t.column("drama_id", .text).primaryKey().references("dramas", onDelete: .cascade)
                t.column("last_episode_id", .text).notNull().references("episodes", onDelete: .cascade)
                t.column("last_episode_number", .integer).notNull()
                t.column("playhead_seconds", .double).notNull().defaults(to: 0.0)
                t.column("duration_seconds", .double).notNull().defaults(to: 0.0)
                t.column("updated_at", .datetime).notNull().indexed()
                t.column("is_completed", .boolean).notNull().defaults(to: false)
            }

            // Watch History table (Chronological event log)
            try db.create(table: "watch_history") { t in
                t.column("id", .text).primaryKey()
                t.column("drama_id", .text).notNull().references("dramas", onDelete: .cascade).indexed()
                t.column("episode_id", .text).notNull().references("episodes", onDelete: .cascade).indexed()
                t.column("episode_number", .integer).notNull()
                t.column("watched_at", .datetime).notNull().indexed()
            }
        }

        // MARK: - v2: Full-Text Search Index (FTS5)
        migrator.registerMigration("v2_fts_indices") { db in
            try db.create(virtualTable: "dramas_fts", using: FTS5()) { t in
                t.synchronize(withTable: "dramas")
                t.column("title")
                t.column("synopsis")
                t.column("cast")
            }
            try db.execute(sql: "INSERT INTO dramas_fts(dramas_fts) VALUES('rebuild')")
        }
    }
}
