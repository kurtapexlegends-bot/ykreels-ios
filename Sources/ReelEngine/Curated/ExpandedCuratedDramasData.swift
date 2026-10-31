import Foundation
import ReelCore

/// Aliases for curated expansion dramas pointing to verified catalog entries.
public enum ExpandedCuratedDramasData {
    public static var finalBossDrama: Drama { CuratedCatalogData.janitor_rise_of_primeDrama }
    public static var finalBossEpisodes: [Episode] { CuratedCatalogData.janitor_rise_of_primeEpisodes }

    public static var ceoContractWifeDrama: Drama { CuratedCatalogData.contract_marriage_tycoonDrama }
    public static var ceoContractWifeEpisodes: [Episode] { CuratedCatalogData.contract_marriage_tycoonEpisodes }

    public static var cursedAlphaDrama: Drama { CuratedCatalogData.if_wishes_could_killDrama }
    public static var cursedAlphaEpisodes: [Episode] { CuratedCatalogData.if_wishes_could_killEpisodes }

    public static var fashionQueenDrama: Drama { CuratedCatalogData.second_first_loveDrama }
    public static var fashionQueenEpisodes: [Episode] { CuratedCatalogData.second_first_loveEpisodes }
}
