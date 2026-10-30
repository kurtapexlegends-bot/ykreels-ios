import Foundation
import ReelCore
import ReelDatabase

/// Result outcome of a remote catalog sync operation.
public enum CatalogSyncResult: Sendable, Equatable {
    case updated(dramasCount: Int, episodesCount: Int)
    case notModified
    case failed(reason: String)
}

/// Service that automatically queries and updates drama series from a remote CDN/feed.
/// Features zero-waste HTTP conditional requests (ETag / 304 Not Modified),
/// local-first SQLite commit, and automatic graceful offline fallback.
public actor RemoteCatalogSyncService {
    public static let shared = RemoteCatalogSyncService()

    public static let defaultFeedURL = URL(
        string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/catalog.json"
    )!

    private let userDefaultsKeyETag = "ykreels.catalog.etag"
    private let userDefaultsKeyLastModified = "ykreels.catalog.last_modified"
    private let userDefaultsKeyCustomURL = "ykreels.catalog.custom_url"

    private var lastSyncAttempt: Date = .distantPast
    private let minimumSyncInterval: TimeInterval = 30.0

    private init() {}

    /// The active remote feed URL (custom URL if set, otherwise default GitHub Raw CDN).
    public var activeFeedURL: URL {
        if let custom = UserDefaults.standard.string(forKey: userDefaultsKeyCustomURL),
           let url = URL(string: custom), !custom.isEmpty {
            return url
        }
        return Self.defaultFeedURL
    }

    /// Sets or clears a custom remote catalog feed URL.
    public func setCustomFeedURL(_ urlString: String?) {
        if let urlString = urlString?.trimmingCharacters(in: .whitespacesAndNewlines), !urlString.isEmpty {
            UserDefaults.standard.set(urlString, forKey: userDefaultsKeyCustomURL)
        } else {
            UserDefaults.standard.removeObject(forKey: userDefaultsKeyCustomURL)
        }
        UserDefaults.standard.removeObject(forKey: userDefaultsKeyETag)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeyLastModified)
    }

    /// Synchronizes catalog with remote endpoint if throttle window has passed or forced.
    @discardableResult
    public func syncCatalog(force: Bool = false) async -> CatalogSyncResult {
        let now = Date()
        if !force && now.timeIntervalSince(lastSyncAttempt) < minimumSyncInterval {
            return .notModified
        }
        lastSyncAttempt = now

        let feedURL = activeFeedURL
        var request = URLRequest(url: feedURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalCacheData

        if !force {
            if let etag = UserDefaults.standard.string(forKey: userDefaultsKeyETag) {
                request.setValue(etag, forHTTPHeaderField: "If-None-Match")
            }
            if let lastMod = UserDefaults.standard.string(forKey: userDefaultsKeyLastModified) {
                request.setValue(lastMod, forHTTPHeaderField: "If-Modified-Since")
            }
        }

        do {
            let sessionConfig = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: sessionConfig)
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failed(reason: "Invalid server response")
            }

            if httpResponse.statusCode == 304 {
                return .notModified
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                return .failed(reason: "HTTP Error \(httpResponse.statusCode)")
            }

            return try await processPayload(data: data, httpResponse: httpResponse)
        } catch {
            return .failed(reason: error.localizedDescription)
        }
    }

    private func processPayload(data: Data, httpResponse: HTTPURLResponse) async throws -> CatalogSyncResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let payload: RemoteCatalogPayload
        do {
            payload = try decoder.decode(RemoteCatalogPayload.self, from: data)
        } catch {
            // Fallback with standard date decoder
            let fallbackDecoder = JSONDecoder()
            payload = try fallbackDecoder.decode(RemoteCatalogPayload.self, from: data)
        }

        try DramaRepository.shared.upsertCatalogItems(payload.items)

        if let etag = httpResponse.allHeaderFields["Etag"] as? String ?? httpResponse.allHeaderFields["ETag"] as? String {
            UserDefaults.standard.set(etag, forKey: userDefaultsKeyETag)
        }
        if let lastMod = httpResponse.allHeaderFields["Last-Modified"] as? String {
            UserDefaults.standard.set(lastMod, forKey: userDefaultsKeyLastModified)
        }

        let totalEpisodes = payload.items.reduce(0) { $0 + $1.episodes.count }
        return .updated(dramasCount: payload.items.count, episodesCount: totalEpisodes)
    }
}
