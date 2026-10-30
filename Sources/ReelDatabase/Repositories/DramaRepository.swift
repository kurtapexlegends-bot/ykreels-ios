import Foundation
import GRDB
import ReelCore

/// Database repository for Drama, Episode, Progress, and Watch History entities.
public final class DramaRepository: Sendable {
    public static let shared = DramaRepository(database: .shared)

    private let database: AppDatabase

    public init(database: AppDatabase) {
        self.database = database
    }

    /// Seeds the curated showcase drama into the database if not present.
    public func seedCuratedDramasIfNeeded(drama: Drama, episodes: [Episode]) {
        do {
            if try fetchDrama(id: drama.id) == nil {
                try upsertDrama(drama)
                try upsertEpisodes(episodes)
            }
        } catch {
            // Keep resilient if database is locked or migrating
        }
    }

    // MARK: - Drama Operations

    /// Saves or updates drama series metadata.
    public func upsertDrama(_ drama: Drama) throws {
        try database.writer.write { db in
            try executeUpsertDrama(db, drama: drama)
        }
    }

    /// Fetches a drama by its unique ID.
    public func fetchDrama(id: String) throws -> Drama? {
        try database.reader.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM dramas WHERE id = ?", arguments: [id]) else {
                return nil
            }
            return parseDrama(from: row)
        }
    }

    /// Fetches all dramas ordered by creation date descending.
    public func fetchAllDramas() throws -> [Drama] {
        try database.reader.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT * FROM dramas ORDER BY created_at DESC")
            return rows.compactMap { parseDrama(from: $0) }
        }
    }

    /// Searches dramas using FTS5 index with fallback to LIKE search.
    public func searchDramas(query: String) throws -> [Drama] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return try fetchAllDramas() }

        return try database.reader.read { db in
            let words = trimmed.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            let sanitizedFts = words.map { "\"" + $0.replacingOccurrences(of: "\"", with: "\"\"") + "\"*" }.joined(separator: " ")
            if let ftsRows = try? Row.fetchAll(
                db,
                sql: """
                SELECT dramas.* FROM dramas
                JOIN dramas_fts ON dramas_fts.rowid = dramas.rowid
                WHERE dramas_fts MATCH ?
                ORDER BY dramas.created_at DESC
                """,
                arguments: [sanitizedFts]
            ), !ftsRows.isEmpty {
                return ftsRows.compactMap { parseDrama(from: $0) }
            }

            let pattern = "%\(trimmed)%"
            let likeRows = try Row.fetchAll(
                db,
                sql: """
                SELECT * FROM dramas
                WHERE title LIKE ? OR synopsis LIKE ? OR cast LIKE ? OR genres LIKE ?
                ORDER BY created_at DESC
                """,
                arguments: [pattern, pattern, pattern, pattern]
            )
            return likeRows.compactMap { parseDrama(from: $0) }
        }
    }

    /// Toggles bookmark state for a drama.
    public func toggleBookmark(dramaId: String) throws -> Bool {
        try database.writer.write { db in
            try db.execute(
                sql: "UPDATE dramas SET is_bookmarked = NOT is_bookmarked, updated_at = ? WHERE id = ?",
                arguments: [Date(), dramaId]
            )
            let row = try Row.fetchOne(db, sql: "SELECT is_bookmarked FROM dramas WHERE id = ?", arguments: [dramaId])
            return (row?["is_bookmarked"] as Bool?) ?? false
        }
    }

    // MARK: - Episode Operations

    /// Saves or updates an episode.
    public func upsertEpisode(_ episode: Episode) throws {
        try database.writer.write { db in
            try executeUpsertEpisode(db, episode: episode)
        }
    }

    /// Bulk saves or updates episodes.
    public func upsertEpisodes(_ episodes: [Episode]) throws {
        try database.writer.write { db in
            for episode in episodes {
                try executeUpsertEpisode(db, episode: episode)
            }
        }
    }

    /// Fetches all episodes for a drama ordered by episode number.
    public func fetchEpisodes(dramaId: String) throws -> [Episode] {
        try database.reader.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: "SELECT * FROM episodes WHERE drama_id = ? ORDER BY episode_number ASC",
                arguments: [dramaId]
            )
            return rows.compactMap { parseEpisode(from: $0) }
        }
    }

    /// Fetches a single episode by ID.
    public func fetchEpisode(id: String) throws -> Episode? {
        try database.reader.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM episodes WHERE id = ?", arguments: [id]) else {
                return nil
            }
            return parseEpisode(from: row)
        }
    }

    /// Updates download state for an episode.
    public func updateDownloadState(episodeId: String, downloadState: DownloadState) throws {
        let stateJson = (try? String(data: JSONEncoder().encode(downloadState), encoding: .utf8)) ?? "\"notDownloaded\""
        try database.writer.write { db in
            try db.execute(
                sql: "UPDATE episodes SET download_state_json = ? WHERE id = ?",
                arguments: [stateJson, episodeId]
            )
        }
    }

    // MARK: - Playback Progress & History

    /// Saves playback progress for a drama.
    public func upsertPlaybackProgress(_ progress: PlaybackProgress) throws {
        try database.writer.write { db in
            try db.execute(
                sql: """
                INSERT INTO playback_progress (drama_id, last_episode_id, last_episode_number, playhead_seconds, duration_seconds, updated_at, is_completed)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(drama_id) DO UPDATE SET
                    last_episode_id = excluded.last_episode_id,
                    last_episode_number = excluded.last_episode_number,
                    playhead_seconds = excluded.playhead_seconds,
                    duration_seconds = excluded.duration_seconds,
                    updated_at = excluded.updated_at,
                    is_completed = excluded.is_completed
                """,
                arguments: [
                    progress.dramaId,
                    progress.lastEpisodeId,
                    progress.lastEpisodeNumber,
                    progress.playheadSeconds,
                    progress.durationSeconds,
                    progress.updatedAt,
                    progress.isCompleted
                ]
            )
        }
    }

    /// Fetches playback progress for a drama.
    public func fetchPlaybackProgress(dramaId: String) throws -> PlaybackProgress? {
        try database.reader.read { db in
            guard let row = try Row.fetchOne(db, sql: "SELECT * FROM playback_progress WHERE drama_id = ?", arguments: [dramaId]) else {
                return nil
            }
            return parsePlaybackProgress(from: row)
        }
    }

    /// Records a watch history event.
    public func recordWatchHistory(_ history: WatchHistory) throws {
        try database.writer.write { db in
            try db.execute(
                sql: """
                INSERT INTO watch_history (id, drama_id, episode_id, episode_number, watched_at)
                VALUES (?, ?, ?, ?, ?)
                """,
                arguments: [
                    history.id,
                    history.dramaId,
                    history.episodeId,
                    history.episodeNumber,
                    history.watchedAt
                ]
            )
        }
    }

    /// Fetches watch history events ordered by watched_at descending.
    public func fetchWatchHistory(limit: Int = 50) throws -> [WatchHistory] {
        try database.reader.read { db in
            let rows = try Row.fetchAll(
                db,
                sql: "SELECT * FROM watch_history ORDER BY watched_at DESC LIMIT ?",
                arguments: [limit]
            )
            return rows.compactMap { row -> WatchHistory? in
                guard let id: String = row["id"],
                      let dramaId: String = row["drama_id"],
                      let episodeId: String = row["episode_id"] else { return nil }
                return WatchHistory(
                    id: id,
                    dramaId: dramaId,
                    episodeId: episodeId,
                    episodeNumber: row["episode_number"] ?? 1,
                    watchedAt: row["watched_at"] ?? Date()
                )
            }
        }
    }

    // MARK: - Private Helpers

    private func executeUpsertDrama(_ db: Database, drama: Drama) throws {
        try db.execute(
            sql: """
            INSERT INTO dramas (id, title, synopsis, cover_url, banner_url, genres, tags, total_episodes, release_year, cast, is_bookmarked, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                title = excluded.title,
                synopsis = excluded.synopsis,
                cover_url = excluded.cover_url,
                banner_url = excluded.banner_url,
                genres = excluded.genres,
                tags = excluded.tags,
                total_episodes = excluded.total_episodes,
                release_year = excluded.release_year,
                cast = excluded.cast,
                is_bookmarked = excluded.is_bookmarked,
                updated_at = excluded.updated_at
            """,
            arguments: [
                drama.id,
                drama.title,
                drama.synopsis,
                drama.coverURL?.absoluteString,
                drama.bannerURL?.absoluteString,
                (try? String(data: JSONEncoder().encode(drama.genres), encoding: .utf8)) ?? "[]",
                (try? String(data: JSONEncoder().encode(drama.tags), encoding: .utf8)) ?? "[]",
                drama.totalEpisodes,
                drama.releaseYear,
                (try? String(data: JSONEncoder().encode(drama.cast), encoding: .utf8)) ?? "[]",
                drama.isBookmarked,
                drama.createdAt,
                drama.updatedAt
            ]
        )
    }

    private func executeUpsertEpisode(_ db: Database, episode: Episode) throws {
        try db.execute(
            sql: """
            INSERT INTO episodes (id, drama_id, episode_number, title, synopsis, duration_seconds, thumbnail_url, stream_sources_json, subtitles_json, is_unlocked, download_state_json)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                drama_id = excluded.drama_id,
                episode_number = excluded.episode_number,
                title = excluded.title,
                synopsis = excluded.synopsis,
                duration_seconds = excluded.duration_seconds,
                thumbnail_url = excluded.thumbnail_url,
                stream_sources_json = excluded.stream_sources_json,
                subtitles_json = excluded.subtitles_json,
                is_unlocked = excluded.is_unlocked,
                download_state_json = excluded.download_state_json
            """,
            arguments: [
                episode.id,
                episode.dramaId,
                episode.episodeNumber,
                episode.title,
                episode.synopsis,
                episode.durationSeconds,
                episode.thumbnailURL?.absoluteString,
                (try? String(data: JSONEncoder().encode(episode.streamSources), encoding: .utf8)) ?? "[]",
                (try? String(data: JSONEncoder().encode(episode.subtitles), encoding: .utf8)) ?? "[]",
                episode.isUnlocked,
                (try? String(data: JSONEncoder().encode(episode.downloadState), encoding: .utf8)) ?? "\"notDownloaded\""
            ]
        )
    }

    private func parseDrama(from row: Row) -> Drama? {
        guard let id: String = row["id"],
              let title: String = row["title"],
              let synopsis: String = row["synopsis"] else { return nil }
        let coverString: String? = row["cover_url"]
        let bannerString: String? = row["banner_url"]
        let genresJson: String = row["genres"] ?? "[]"
        let genres = (try? JSONDecoder().decode([String].self, from: Data(genresJson.utf8))) ?? []
        let tagsJson: String = row["tags"] ?? "[]"
        let tags = (try? JSONDecoder().decode([String].self, from: Data(tagsJson.utf8))) ?? []
        let castJson: String = row["cast"] ?? "[]"
        let cast = (try? JSONDecoder().decode([String].self, from: Data(castJson.utf8))) ?? []

        return Drama(
            id: id,
            title: title,
            synopsis: synopsis,
            coverURL: coverString.flatMap { URL(string: $0) },
            bannerURL: bannerString.flatMap { URL(string: $0) },
            genres: genres,
            tags: tags,
            totalEpisodes: row["total_episodes"] ?? 0,
            releaseYear: row["release_year"] ?? 2024,
            cast: cast,
            isBookmarked: row["is_bookmarked"] ?? false,
            createdAt: row["created_at"] ?? Date(),
            updatedAt: row["updated_at"] ?? Date()
        )
    }

    private func parseEpisode(from row: Row) -> Episode? {
        guard let id: String = row["id"],
              let dramaId: String = row["drama_id"],
              let episodeNumber: Int = row["episode_number"],
              let title: String = row["title"] else { return nil }
        let thumbString: String? = row["thumbnail_url"]
        let sourcesJson: String = row["stream_sources_json"] ?? "[]"
        let sources = (try? JSONDecoder().decode([StreamSource].self, from: Data(sourcesJson.utf8))) ?? []
        let subsJson: String = row["subtitles_json"] ?? "[]"
        let subs = (try? JSONDecoder().decode([SubtitleTrack].self, from: Data(subsJson.utf8))) ?? []
        let dlJson: String = row["download_state_json"] ?? "\"notDownloaded\""
        let dlState = (try? JSONDecoder().decode(DownloadState.self, from: Data(dlJson.utf8))) ?? .notDownloaded

        return Episode(
            id: id,
            dramaId: dramaId,
            episodeNumber: episodeNumber,
            title: title,
            synopsis: row["synopsis"],
            durationSeconds: row["duration_seconds"] ?? 0.0,
            thumbnailURL: thumbString.flatMap { URL(string: $0) },
            streamSources: sources,
            subtitles: subs,
            isUnlocked: row["is_unlocked"] ?? true,
            downloadState: dlState
        )
    }

    private func parsePlaybackProgress(from row: Row) -> PlaybackProgress? {
        guard let dramaId: String = row["drama_id"],
              let lastEpId: String = row["last_episode_id"],
              let lastEpNum: Int = row["last_episode_number"] else { return nil }
        return PlaybackProgress(
            dramaId: dramaId,
            lastEpisodeId: lastEpId,
            lastEpisodeNumber: lastEpNum,
            playheadSeconds: row["playhead_seconds"] ?? 0.0,
            durationSeconds: row["duration_seconds"] ?? 0.0,
            updatedAt: row["updated_at"] ?? Date(),
            isCompleted: row["is_completed"] ?? false
        )
    }
}
