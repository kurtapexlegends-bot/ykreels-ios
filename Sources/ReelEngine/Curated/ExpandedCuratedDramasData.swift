import Foundation
import ReelCore

/// Curated catalog expansion containing popular short-drama series across top genres:
/// 1. Move Aside! I'm the Final Boss (Hidden Billionaire / Revenge)
/// 2. The CEO's Contract Wife (Contract Marriage / CEO Romance)
/// 3. The Cursed Alpha's Mate (Werewolf / Fantasy Romance)
/// 4. The Fashion Queen Strikes Back (Workplace Drama / Glow-Up)
public enum ExpandedCuratedDramasData {

    private static let verticalStreamURLs: [URL] = [
        // 0: Contract Marriage With the Arms Tycoon
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/011_7626295115027401997_720x1280_Contract%20Marriage%20With%20the%20Arms%20Tycoon-%20Link%20in%20bio%20-%20Search%20%26%20Watch%20All%20Series.mp4")!,
        // 1: Contract stranger marriage
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/012_7649670011711261966_720x1280_%E3%80%8A%E5%8D%8A%E7%86%9F%E6%81%8B%E4%BA%BA%E3%80%8Bpart%2061%20I%20thought%20I%20married%20a%20stranger%20for%20a%20contract%2C%20but%20the.mp4")!,
        // 2: Bella encounters Edward Hoffman (CEO)
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/013_7649022892008590623_720x1280_Ep%203_Part%203_%20Bella%20encounters%20Edward%20Hoffman%2C%20a%20CEO%20she%20finds%20familiar%20but%20doubt.mp4")!,
        // 3: Fiancé's family doubts
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/006_7647902598808227103_720x1280_Ep%202_Episode%202_%20The%20girl%20arrives%20at%20the%20fianc%C3%A9%27s%20family%20and%20is%20met%20with%20doubts.mp4")!,
        // 4: ReelShort App official episode
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/001_7649606083882896653_720x1280_Ep%203_%F0%9F%8C%9F%20Continue%20the%20story%20here%20%F0%9F%91%89%F0%9F%8F%BB%20%F0%9F%93%B2%20Download%20the%20%E2%80%9CReelShort%E2%80%9D%20app.mp4")!,
        // 5: My Husband's Secret
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/010_7648924968813743381_720x1280_%F0%9F%93%BA%20%F0%9D%99%88%F0%9D%99%AE%20%F0%9D%99%83%F0%9D%99%AA%F0%9D%99%A8%F0%9D%99%97%F0%9D%99%96%F0%9D%99%A3%F0%9D%99%99%27%F0%9D%99%A8%20%F0%9D%99%8E%F0%9D%99%9A%F0%9D%99%98%F0%9D%99%A7%F0%9D%99%9A%F0%9D%99%A9%20%F0%9D%98%BE.mp4")!,
        // 6: Taming My Bullies 2
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/002_7643225818440781070_720x1280_%F0%9F%8E%AC%F0%9D%99%8F%F0%9D%99%96%F0%9D%99%A2%F0%9D%99%9E%F0%9D%99%A3%F0%9D%99%9C%20%F0%9D%99%88%F0%9D%99%AE%20%F0%9D%98%BD%F0%9D%99%AA%F0%9D%99%A1%F0%9D%99%A1%F0%9D%99%9E%F0%9D%99%9A%F0%9D%99%A8%202%20is%20now%20stre.mp4")!,
        // 7: MoboReels popular reel
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/008_7644507197778496798_720x1280_%F0%9F%8C%9FContinuethestoryhere%20%F0%9F%91%89%F0%9F%8F%BB%F0%9F%93%B2Downloadthe_MoboReels_app%2C%20%F0%9F%94%8Dsearchfor_84.mp4")!,
        // 8: FlickReels drama
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134357Z/010_7565673804605705490_720x1280_%E3%83%A4%E3%83%B3%E3%83%87%E3%83%AC%E3%81%AE%E5%BC%B7%E5%88%B6%E6%84%9B-4%20%E2%9C%A8FlickReels%E3%82%A2%E3%83%97%E3%83%AA%E3%82%92%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89%E3%81%99%E3%82%8B.mp4")!,
        // 9: Trending short-drama
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134524Z/011_7458979992546970888_576x1024_%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E4%B8%8A%E7%83%AD%E9%97%A8%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E7%83%AD%E6%92%AD%E7%9F%AD%E5%89%A7%E6%8C%81%E7%BB%AD%E6%9B%B4%E6%96%B0%E4%B8%AD%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E5%AE%98%20%23.mp4")!
    ]

    // MARK: - Helper Stream Generator
    private static func makeStreams(prefix: String, ep: Int, offset: Int) -> [StreamSource] {
        let primaryURL = verticalStreamURLs[(offset + ep - 1) % verticalStreamURLs.count]
        let secondaryURL = verticalStreamURLs[(offset + ep) % verticalStreamURLs.count]
        return [
            StreamSource(id: "\(prefix)-mp4-\(ep)-pri", url: primaryURL, format: .mp4, quality: .fhd1080p, isDefault: true),
            StreamSource(id: "\(prefix)-mp4-\(ep)-sec", url: secondaryURL, format: .mp4, quality: .hd720p, isDefault: false)
        ]
    }

    // MARK: - 1. Move Aside! I'm the Final Boss
    public static let finalBossDrama = Drama(
        id: "drama-final-boss",
        title: "Move Aside! I'm the Final Boss",
        synopsis: "Dumped by his materialistic fiancée on their anniversary for being 'just a delivery driver', Ethan reveals his true identity as the reclusive global tycoon controlling the city's largest financial empire.",
        coverURL: URL(string: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600&auto=format&fit=crop&q=80"),
        bannerURL: URL(string: "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=1200&auto=format&fit=crop&q=80"),
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
            streamSources: makeStreams(prefix: "fb", ep: i, offset: 2)
        )
    }

    // MARK: - 2. The CEO's Contract Wife
    public static let ceoContractWifeDrama = Drama(
        id: "drama-ceo-contract-wife",
        title: "The CEO's Contract Wife",
        synopsis: "To pay for her grandmother's urgent medical treatment, quiet accountant Clara enters a strict 1-year marriage contract with the ruthless billionaire Damien Vance. But what began as business quickly turns into irresistible passion.",
        coverURL: URL(string: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=80"),
        bannerURL: URL(string: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200&auto=format&fit=crop&q=80"),
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
            streamSources: makeStreams(prefix: "ccw", ep: i, offset: 4)
        )
    }

    // MARK: - 3. The Cursed Alpha's Mate
    public static let cursedAlphaDrama = Drama(
        id: "drama-cursed-alpha",
        title: "The Cursed Alpha's Mate",
        synopsis: "Exiled from the Silvercrest Pack after being falsely accused of treason, half-wolf healer Maeve discovers the cursed, feared Alpha King Kaelen in the forbidden mountains—only to realize he is her destined fated mate.",
        coverURL: URL(string: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600&auto=format&fit=crop&q=80"),
        bannerURL: URL(string: "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80"),
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
            streamSources: makeStreams(prefix: "cam", ep: i, offset: 6)
        )
    }

    // MARK: - 4. The Fashion Queen Strikes Back
    public static let fashionQueenDrama = Drama(
        id: "drama-fashion-queen",
        title: "The Fashion Queen Strikes Back",
        synopsis: "After her designs are stolen by a privileged nepo-baby and she is publicly fired, brilliant couture stylist Maya launches an undercover luxury label that sparks an international fashion war.",
        coverURL: URL(string: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&auto=format&fit=crop&q=80"),
        bannerURL: URL(string: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&auto=format&fit=crop&q=80"),
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
            streamSources: makeStreams(prefix: "fq", ep: i, offset: 8)
        )
    }
}
