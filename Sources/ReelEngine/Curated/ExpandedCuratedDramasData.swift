import Foundation
import ReelCore

/// Curated catalog expansion containing popular short-drama series across top genres:
/// 1. Move Aside! I'm the Final Boss (Hidden Billionaire / Revenge)
/// 2. The CEO's Contract Wife (Contract Marriage / CEO Romance)
/// 3. The Cursed Alpha's Mate (Werewolf / Fantasy Romance)
/// 4. The Fashion Queen Strikes Back (Workplace Drama / Glow-Up)
public enum ExpandedCuratedDramasData {

    // MARK: - Helper Stream Generator
    private static func makeStreams(prefix: String, ep: Int) -> [StreamSource] {
        let formatted = String(format: "%02d", ep)
        return [
            StreamSource(
                id: "\(prefix)-hls-\(ep)",
                url: URL(string: "https://stream.ykreels.internal/dramas/\(prefix)/ep\(formatted)/index.m3u8")!,
                format: .hls,
                quality: .fhd1080p,
                isDefault: true
            ),
            StreamSource(
                id: "\(prefix)-mp4-\(ep)",
                url: URL(string: "https://stream.ykreels.internal/dramas/\(prefix)/ep\(formatted)/1080p.mp4")!,
                format: .mp4,
                quality: .hd720p,
                isDefault: false
            )
        ]
    }

    // MARK: - 1. Move Aside! I'm the Final Boss
    public static let finalBossDrama = Drama(
        id: "drama-final-boss",
        title: "Move Aside! I'm the Final Boss",
        synopsis: "Dumped by his materialistic fiancée on their anniversary for being 'just a delivery driver', Ethan reveals his true identity as the reclusive global tycoon controlling the city's largest financial empire.",
        coverURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/final-boss/cover.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/final-boss/banner.jpg"),
        genres: ["Billionaire", "Revenge", "Drama"],
        tags: ["Hidden Identity", "Underdog", "Payback"],
        totalEpisodes: 30,
        releaseYear: 2024,
        cast: ["Ethan (Tycoon)", "Victoria (Ex-Fiancée)", "Harrison (Rival Heir)", "Seraphina (Allied CEO)"]
    )

    public static let finalBossEpisodes: [Episode] = (1...30).map { i in
        Episode(
            id: "ep-fb-\(String(format: "%02d", i))",
            dramaId: "drama-final-boss",
            episodeNumber: i,
            title: i == 1 ? "The Anniversary Humiliation" : i == 30 ? "All Bow to the Boss" : "The Reckoning Pt. \(i)",
            synopsis: "Ethan systematically unmasks the corrupt elite while protecting the innocent.",
            durationSeconds: Double(90 + (i % 30)),
            streamSources: makeStreams(prefix: "fb", ep: i)
        )
    }

    // MARK: - 2. The CEO's Contract Wife
    public static let ceoContractWifeDrama = Drama(
        id: "drama-ceo-contract-wife",
        title: "The CEO's Contract Wife",
        synopsis: "To pay for her grandmother's urgent medical treatment, quiet accountant Clara enters a strict 1-year marriage contract with the ruthless billionaire Damien Vance. But what began as business quickly turns into irresistible passion.",
        coverURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/ceo-contract/cover.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/ceo-contract/banner.jpg"),
        genres: ["Romance", "Billionaire", "Drama"],
        tags: ["Contract Marriage", "Enemies to Lovers", "CEO"],
        totalEpisodes: 28,
        releaseYear: 2024,
        cast: ["Clara (Accountant)", "Damien (CEO)", "Vivian (Socialite Rival)", "Julian (Family Lawyer)"]
    )

    public static let ceoContractWifeEpisodes: [Episode] = (1...28).map { i in
        Episode(
            id: "ep-ccw-\(String(format: "%02d", i))",
            dramaId: "drama-ceo-contract-wife",
            episodeNumber: i,
            title: i == 1 ? "The Proposal at Midnight" : i == 28 ? "A Real Vow" : "Contract Clause #\(i)",
            synopsis: "Damien discovers Clara is unlike any woman in high society, and guards her fiercely.",
            durationSeconds: Double(95 + (i % 25)),
            streamSources: makeStreams(prefix: "ccw", ep: i)
        )
    }

    // MARK: - 3. The Cursed Alpha's Mate
    public static let cursedAlphaDrama = Drama(
        id: "drama-cursed-alpha",
        title: "The Cursed Alpha's Mate",
        synopsis: "Exiled from the Silvercrest Pack after being falsely accused of treason, half-wolf healer Maeve discovers the cursed, feared Alpha King Kaelen in the forbidden mountains—only to realize he is her destined fated mate.",
        coverURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/cursed-alpha/cover.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/cursed-alpha/banner.jpg"),
        genres: ["Fantasy", "Romance", "Werewolf"],
        tags: ["Fated Mates", "Alpha King", "Forbidden Love"],
        totalEpisodes: 26,
        releaseYear: 2024,
        cast: ["Maeve (Healer)", "Kaelen (Alpha King)", "Torin (Usurper)", "Lyra (Beta Guard)"]
    )

    public static let cursedAlphaEpisodes: [Episode] = (1...26).map { i in
        Episode(
            id: "ep-cam-\(String(format: "%02d", i))",
            dramaId: "drama-cursed-alpha",
            episodeNumber: i,
            title: i == 1 ? "Exiled to the Mist" : i == 26 ? "The Crown of the Moon" : "Pack Shadows Pt. \(i)",
            synopsis: "Kaelen's dark curse softens only under Maeve's touch as war looms over the realm.",
            durationSeconds: Double(100 + (i % 20)),
            streamSources: makeStreams(prefix: "cam", ep: i)
        )
    }

    // MARK: - 4. The Fashion Queen Strikes Back
    public static let fashionQueenDrama = Drama(
        id: "drama-fashion-queen",
        title: "The Fashion Queen Strikes Back",
        synopsis: "After her designs are stolen by a privileged nepo-baby and she is publicly fired, brilliant couture stylist Maya launches an undercover luxury label that sparks an international fashion war.",
        coverURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/fashion-queen/cover.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/fashion-queen/banner.jpg"),
        genres: ["Drama", "Revenge", "Romance"],
        tags: ["Workplace", "Glow-Up", "Fashion Empire"],
        totalEpisodes: 24,
        releaseYear: 2024,
        cast: ["Maya (Designer)", "Liam (Venture Capitalist)", "Giselle (Design Thief)", "Antoine (Fashion Critic)"]
    )

    public static let fashionQueenEpisodes: [Episode] = (1...24).map { i in
        Episode(
            id: "ep-fq-\(String(format: "%02d", i))",
            dramaId: "drama-fashion-queen",
            episodeNumber: i,
            title: i == 1 ? "Stolen Dreams on the Runway" : i == 24 ? "Paris Coronation" : "Haute Couture War Pt. \(i)",
            synopsis: "Maya's rebellious anonymous collection shocks Milan, leaving her former bosses ruined.",
            durationSeconds: Double(92 + (i % 28)),
            streamSources: makeStreams(prefix: "fq", ep: i)
        )
    }
}
