import Foundation

/// Core domain errors for YKReels.
public enum ReelError: LocalizedError, Sendable {
    case dramaNotFound(String)
    case episodeNotFound(String)
    case streamUnavailable(String)
    case playerInitFailed(String)
    case networkError(String)
    case databaseError(String)
    case downloadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .dramaNotFound(let message):
            return "Drama not found: \(message)"
        case .episodeNotFound(let message):
            return "Episode not found: \(message)"
        case .streamUnavailable(let message):
            return "Stream unavailable: \(message)"
        case .playerInitFailed(let message):
            return "Player initialization failed: \(message)"
        case .networkError(let message):
            return "Network connection issue: \(message)"
        case .databaseError(let message):
            return "Storage failure: \(message)"
        case .downloadFailed(let message):
            return "Episode download failed: \(message)"
        }
    }
}
