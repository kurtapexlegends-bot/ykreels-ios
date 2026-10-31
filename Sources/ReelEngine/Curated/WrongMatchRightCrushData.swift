import Foundation
import ReelCore

/// Flagship launch starter drama alias wired to verified vertical series:
/// "Taming My Bullies". Preserves 100% backward compatibility for all test suites.
public enum WrongMatchRightCrushData {
    public static var drama: Drama { CuratedCatalogData.taming_my_bulliesDrama }
    public static var dramaId: String { CuratedCatalogData.taming_my_bulliesDrama.id }
    public static var episodes: [Episode] { CuratedCatalogData.taming_my_bulliesEpisodes }
}
