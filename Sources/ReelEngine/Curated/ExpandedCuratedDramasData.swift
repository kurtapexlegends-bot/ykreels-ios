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
        // 1: Arrival at fiancé's family
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/006_7647902598808227103_720x1280_Ep%202_Episode%202_%20The%20girl%20arrives%20at%20the%20fianc%C3%A9%27s%20family%20and%20is%20met%20with%20doubts.mp4")!,
        // 2: Grandma's 2-Year Contract
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/016_7649585478529797407_720x1280_Ep%203_Episode%203_%20Grandma%E2%80%99s%20deathbed%20wish%20forces%20Emily%20into%20a%202-year%20contract%20wi.mp4")!,
        // 3: Contract Marriage Part 94
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/017_7648669635025374482_720x1280_Contract%20Marriage%20Part-94_....%E2%9C%A8.mp4")!,
        // 4: My Alpha Boss Gave Me Triplets
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/009_7649296634114788621_720x1280_Full%20Ep%20in%20Bio%21%20Watch%20the%20minidrama%20My%20Alpha%20Boss%20Gave%20Me%20Triplets%20for%20FREE.mp4")!,
        // 5: ReelShort Official Vertical Drama
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/011_7649196886359936269_720x1280_%23reelshort%20%23microdrama%20%23vertical%20%23acting%20%23itscamsworld.mp4")!,
        // 6: No More Secretary, No More Secret Lover
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/048_7649597103739538719_720x1280_No%20More%20Secretary%2C%20No%20More%20Secret%20Lover%2005%20%23dramabox%20%23drama%20%23shortsdrama%20%23shortf.mp4")!,
        // 7: AI USA Short Drama / ReelShort
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T085021Z/033_7647390841241160990_720x1280_%23AI%20%23TikTokMinis%20%23USAShortDrama%20%23ReelShort%20%23FYP.mp4")!,
        // 8: His Cure His Wife
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T085021Z/035_7648241565810429201_720x1280_EP-01%20HIS%20CURE%20HIS%20WIFE%20%23drama%20%23viral%20%23shortdrama%20%23skit%20%23hiscurehiswife.mp4")!,
        // 9: Taming My Bullies 1080x1920 Full HD
        URL(string: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T095109Z/052_7646490757162863886_1080x1920_Emma%20stays%20stressed%20fr%20%40itscamsworld%20%23reelshort%20%23tamingmybullies%20%23iykyk%20%23vertica.mp4")!
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
