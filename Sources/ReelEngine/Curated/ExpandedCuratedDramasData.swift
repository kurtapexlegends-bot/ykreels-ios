import Foundation
import ReelCore

/// Curated catalog expansion containing popular short-drama series across top genres:
/// 1. Move Aside! I'm the Final Boss (Hidden Billionaire / Revenge)
/// 2. The CEO's Contract Wife (Contract Marriage / CEO Romance)
/// 3. The Cursed Alpha's Mate (Werewolf / Fantasy Romance)
/// 4. The Fashion Queen Strikes Back (Workplace Drama / Glow-Up)
public enum ExpandedCuratedDramasData {

    private static let verticalStreamURLs: [URL] = [
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134524Z/001_7649607267184102664_576x1024_%2849%29%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90_%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E5%B9%BF_%23%E5%A4%A7%E7%BB%93%E5%B1%80%E5%A4%AA%E7%B2%BE%E5%BD%A9%E4%BA%86.mp4")!,
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134524Z/003_7634421520667839752_576x1024_%23%E5%B0%8F%E8%AA%AA%E6%8E%A8%E6%96%87%20%23%E5%B0%8F%E8%AA%AA%E6%8E%A8%E8%96%A6%20%23fyp%20%23%E5%B0%8F%E8%AA%AA.mp4")!,
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134357Z/007_7634317672930561301_576x1024_7634317672930561301.mp4")!,
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134357Z/010_7565673804605705490_720x1280_%E3%83%A4%E3%83%B3%E3%83%87%E3%83%AC%E3%81%AE%E5%BC%B7%E5%88%B6%E6%84%9B-4%20%E2%9C%A8FlickReels%E3%82%A2%E3%83%97%E3%83%AA%E3%82%92%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89%E3%81%99%E3%82%8B.mp4")!,
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T134524Z/011_7458979992546970888_576x1024_%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E4%B8%8A%E7%83%AD%E9%97%A8%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E7%83%AD%E6%92%AD%E7%9F%AD%E5%89%A7%E6%8C%81%E7%BB%AD%E6%9B%B4%E6%96%B0%E4%B8%AD%23%E7%9F%AD%E5%89%A7%E6%8E%A8%E8%8D%90%E5%AE%98%20%23.mp4")!
    ]

    // MARK: - Helper Stream Generator
    private static func makeStreams(prefix: String, ep: Int) -> [StreamSource] {
        let primaryURL = verticalStreamURLs[(ep - 1) % verticalStreamURLs.count]
        let secondaryURL = verticalStreamURLs[ep % verticalStreamURLs.count]
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
            streamSources: makeStreams(prefix: "fb", ep: i)
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
            streamSources: makeStreams(prefix: "ccw", ep: i)
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
            streamSources: makeStreams(prefix: "cam", ep: i)
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
            streamSources: makeStreams(prefix: "fq", ep: i)
        )
    }
}
