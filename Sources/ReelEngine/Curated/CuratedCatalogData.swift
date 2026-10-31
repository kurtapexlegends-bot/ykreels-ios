import Foundation
import ReelCore

/// Pre-bundled, zero-latency starter catalog containing 12 verified vertical micro-dramas.
/// Provides instant offline catalog readiness before remote sync.
public enum CuratedCatalogData {

    private static func makeEpisode(id: String, dramaId: String, ep: Int, title: String, synopsis: String, dur: Double, url: String, cover: String) -> Episode {
        Episode(
            id: id,
            dramaId: dramaId,
            episodeNumber: ep,
            title: title,
            synopsis: synopsis,
            durationSeconds: dur,
            thumbnailURL: URL(string: cover),
            streamSources: [
                StreamSource(id: "\(id)-pri", url: URL(string: url)!, format: .mp4, quality: .fhd1080p, isDefault: true)
            ],
            subtitles: [],
            isUnlocked: true,
            downloadState: .notDownloaded
        )
    }

    // MARK: - 1. Taming My Bullies
    public static let taming_my_bulliesDrama = Drama(
        id: "taming-my-bullies",
        title: "Taming My Bullies",
        synopsis: "Forced to transfer to an elite academy, Emma finds herself targeted by the school's notorious hockey crew—until team captain Rowan develops an obsessive, protective fixation on her.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        genres: ["Romance", "High School", "Enemies to Lovers"],
        tags: ["Bad Boy", "Campus", "Protective"],
        totalEpisodes: 7,
        releaseYear: 2024,
        cast: ["Emma (Transfer Student)", "Rowan (Hockey Captain)", "Cam (Rival Center)"],
        isBookmarked: false
    )

    public static let taming_my_bulliesEpisodes: [Episode] = [
        makeEpisode(id: "ep-taming-my-bullies-01", dramaId: "taming-my-bullies", ep: 1, title: "Emma Meets Rowan", synopsis: "First day on campus takes a wild turn when Emma walks right into the hockey captain's locker room.", dur: 15.033, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T095109Z/039_7649130461813361933_1080x1920_We%20clearly%20have%20too%20much%20content%20from%20this%20shoot%20%40itscamsworld%20%23tamingmybullies.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-02", dramaId: "taming-my-bullies", ep: 2, title: "Rowan's Love Languages", synopsis: "Rowan makes it clear to the entire school that anyone targeting Emma answers to him.", dur: 19.467, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T085021Z/032_7645030881219988750_720x1280_%F0%9F%8E%AC%20Taming%20My%20Bullies%202%20Rowan%E2%80%99s%20love%20languages%20%F0%9F%92%97%20%23ReelShort%20%23TamingMyBulli.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-03", dramaId: "taming-my-bullies", ep: 3, title: "The Secret Shoot", synopsis: "Caught together after hours, Rowan gives Emma an ultimatum she cannot refuse.", dur: 23.833, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T085021Z/038_7639812757163920653_720x1280_%F0%9F%8E%AC%20Taming%20My%20Bullies%20We%20miss%20you%20too%21%20See%20you%20soon%E2%99%A5%EF%B8%8F%20%23ReelShort%20%23TamingMyB.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-04", dramaId: "taming-my-bullies", ep: 4, title: "Tennis Lessons with Emma", synopsis: "Rowan crashes Emma's tennis session, challenging her to an intense bet.", dur: 28.233, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T165926Z/116_7649527600523578637_720x1280_%F0%9F%8E%AC%20Taming%20My%20Bullies%203%20%F0%9F%8E%BE%20I%27d%20like%20to%20sign%20up%20for%20Emma%27s%20tennis%20lessons%20%23Ree.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-05", dramaId: "taming-my-bullies", ep: 5, title: "Reel Love Truth", synopsis: "The truth about Rowan's protective instincts comes to light at the ice rink.", dur: 14.0, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1648_7649518900253560078_720x1280_%F0%9F%8E%AC%20Taming%20My%20Bullies%203%20wait...%20I%20didn%27t%20know%20this%20counted%20as%20Reel%20Love%20%F0%9F%98%AD%20%23R.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-06", dramaId: "taming-my-bullies", ep: 6, title: "The Rivalry Escalates", synopsis: "A confrontation in the hallway forces Rowan to publicly claim Emma as his.", dur: 69.25, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1171_7642983397425564941_720x1280_Full%20Ep%20in%20Bio%21%20Watch%20the%20minidrama%20Taming%20My%20Bullies%202%20for%20FREE.%20%F0%9F%8D%BFFind%20out%20w.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
        makeEpisode(id: "ep-taming-my-bullies-07", dramaId: "taming-my-bullies", ep: 7, title: "High School Queen Feature", synopsis: "Full uncut 48-minute campus drama showdown between Emma, Rowan, and the rival squad.", dur: 2902.5, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/2203_7640947370015853855_576x1254_knocked%20out%20by%20the%20high%20school%20queen%20%23fyp%20%23reelshort%20%23verticalmovies%20%23shorts%20%23dr.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/taming-my-bullies.jpg"),
    ]

    // MARK: - 2. Contract Marriage With the Arms Tycoon
    public static let contract_marriage_tycoonDrama = Drama(
        id: "contract-marriage-tycoon",
        title: "Contract Marriage With the Arms Tycoon",
        synopsis: "To settle her family's crushing debts, Emily enters a strict 2-year contract marriage with reclusive global arms tycoon Edward Hoffman—unaware that she is the childhood girl he spent a decade seeking.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        genres: ["Billionaire", "Contract Marriage", "CEO Romance"],
        tags: ["Fake Marriage", "Secret Identity", "Enemies to Lovers"],
        totalEpisodes: 7,
        releaseYear: 2024,
        cast: ["Emily (Contract Bride)", "Edward Hoffman (Arms Tycoon)", "Grandma Hoffman"],
        isBookmarked: false
    )

    public static let contract_marriage_tycoonEpisodes: [Episode] = [
        makeEpisode(id: "ep-contract-marriage-tycoon-01", dramaId: "contract-marriage-tycoon", ep: 1, title: "The Contract Proposal", synopsis: "Edward Hoffman offers Emily a 2-year marriage contract with life-altering terms.", dur: 100.9, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/011_7626295115027401997_720x1280_Contract%20Marriage%20With%20the%20Arms%20Tycoon-%20Link%20in%20bio%20-%20Search%20%26%20Watch%20All%20Series.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-02", dramaId: "contract-marriage-tycoon", ep: 2, title: "Arrival at the Fiancé's Family", synopsis: "Emily arrives at the grand Hoffman estate and faces skeptical high-society in-laws.", dur: 71.44, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/006_7647902598808227103_720x1280_Ep%202_Episode%202_%20The%20girl%20arrives%20at%20the%20fianc%C3%A9%27s%20family%20and%20is%20met%20with%20doubts.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-03", dramaId: "contract-marriage-tycoon", ep: 3, title: "Grandma's 2-Year Contract", synopsis: "Grandma Hoffman's deathbed wish locks the contract into irrevocable stone.", dur: 46.6, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/016_7649585478529797407_720x1280_Ep%203_Episode%203_%20Grandma%E2%80%99s%20deathbed%20wish%20forces%20Emily%20into%20a%202-year%20contract%20wi.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-04", dramaId: "contract-marriage-tycoon", ep: 4, title: "Bella Encounters Edward", synopsis: "A chance rooftop encounter reveals Edward's hidden vulnerability.", dur: 138.32, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/013_7649022892008590623_720x1280_Ep%203_Part%203_%20Bella%20encounters%20Edward%20Hoffman%2C%20a%20CEO%20she%20finds%20familiar%20but%20doubt.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-05", dramaId: "contract-marriage-tycoon", ep: 5, title: "The Secret Heiress & Tycoon", synopsis: "Emily's real bloodline starts to unravel in front of the city's financial elite.", dur: 269.867, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/003_7574305067101130004_576x1274_From%20Contract%20Bride%20to%20CEO_%20The%20Secret%20Heiress%20and%20Her%20Billionaire%20Husband%20Part.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-06", dramaId: "contract-marriage-tycoon", ep: 6, title: "Contract and Heart", synopsis: "Fake feelings turn shockingly real during an unexpected company gala.", dur: 308.767, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/002_7637812649392164109_720x1280_Part%201%20%F0%9F%92%98Contract%20and%20heart%20%F0%9F%92%A8%20Follow%20me%20for%20the%20next%20part%20%23shortsdrama%20%23plo.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
        makeEpisode(id: "ep-contract-marriage-tycoon-07", dramaId: "contract-marriage-tycoon", ep: 7, title: "The Final Vow", synopsis: "The grand finale: Emily and Edward renew their vows—this time without any contract.", dur: 783.267, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T154911Z/017_7648669635025374482_720x1280_Contract%20Marriage%20Part-94_....%E2%9C%A8.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/contract-marriage-tycoon.jpg"),
    ]

    // MARK: - 3. The Janitor: Rise of the Prime
    public static let janitor_rise_of_primeDrama = Drama(
        id: "janitor-rise-of-prime",
        title: "The Janitor: Rise of the Prime",
        synopsis: "Ethan, the supreme head of the Prime Financial Syndicate, poses as a humble building janitor to root out corruption and teach his materialistic ex-fiancée an unforgettable lesson.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
        genres: ["Hidden Billionaire", "Revenge", "Action"],
        tags: ["Undercover", "Tycoon", "Payback"],
        totalEpisodes: 4,
        releaseYear: 2024,
        cast: ["Ethan (The Prime / Janitor)", "Sarah (Ex-Fianc\u00e9e)", "Director Vance"],
        isBookmarked: false
    )

    public static let janitor_rise_of_primeEpisodes: [Episode] = [
        makeEpisode(id: "ep-janitor-rise-of-prime-01", dramaId: "janitor-rise-of-prime", ep: 1, title: "The Janitor Billionaire Unveiled", synopsis: "Dumped for sweeping floors, Ethan watches his ex brag to her new arrogant suitor.", dur: 38.633, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1816_7638752526287850765_720x1280_she%E2%80%99s%20not%20choosing%E2%80%A6%20she%E2%80%99s%20buffering.%20%F0%9F%93%BA%20The%20Janitor%20Billionaire%20%26%20His%20Sw.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
        makeEpisode(id: "ep-janitor-rise-of-prime-02", dramaId: "janitor-rise-of-prime", ep: 2, title: "The Billionaire Returns", synopsis: "Ethan enters the boardroom in his uniform as the global board bows in absolute terror.", dur: 29.2, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1834_7650402441640561941_720x1280_The%20Janitor%20Billionaire%20%23aigenerated%20%23shorts%20%23shortdrama%20%23.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
        makeEpisode(id: "ep-janitor-rise-of-prime-03", dramaId: "janitor-rise-of-prime", ep: 3, title: "The Janitor Strikes Back", synopsis: "17-minute explosive retaliation: Ethan cancels the multimillion contracts of everyone who crossed him.", dur: 1015.533, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1827_7650474560776572190_720x1280_The%20Janitor%20Billionaire%20Strikes%20Back%20is%20now%20on%20the%20NetShort%20APP%21%20Download%20the%20AP.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
        makeEpisode(id: "ep-janitor-rise-of-prime-04", dramaId: "janitor-rise-of-prime", ep: 4, title: "Rise of the Prime Master Feature", synopsis: "The full 60-minute uncut master feature of Ethan reclaiming his global throne.", dur: 3583.52, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/3169_7650670395942587669_720x1280_The%20Janitor%20%E2%80%93%20Rise%20Of%20The%20Prime%20HD%20Part%201-2%20.%20.%20If%20you%20like%20my%20post%20please%20FOL.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/janitor-rise-of-prime.jpg"),
    ]

    // MARK: - 4. If Wishes Could Kill
    public static let if_wishes_could_killDrama = Drama(
        id: "if-wishes-could-kill",
        title: "If Wishes Could Kill",
        synopsis: "When betrayed heiress Clara survives a staged cliff crash, an ancient family relic grants her lethal premonitions. Returning under a new persona, she dismantles the syndicate that ruined her family.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/if-wishes-could-kill.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/if-wishes-could-kill.jpg"),
        genres: ["Suspense", "Revenge", "Mystery"],
        tags: ["Betrayal", "Premonition", "Heiress"],
        totalEpisodes: 1,
        releaseYear: 2024,
        cast: ["Clara Vance (Heiress)", "Julian Sterling (Rival Tycoon)", "Marcus"],
        isBookmarked: false
    )

    public static let if_wishes_could_killEpisodes: [Episode] = [
        makeEpisode(id: "ep-if-wishes-could-kill-01", dramaId: "if-wishes-could-kill", ep: 1, title: "Episode 1 Full Master Feature", synopsis: "Complete 58-minute continuous vertical suspense drama of Clara's miraculous survival and methodical revenge.", dur: 3501.433, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/4354_7638549215244782868_720x1280_If%20Wishes%20Could%20Kill%20%E2%9C%A8%20Episode%201%20%28Full%20Part%29%20%23ifwishescouldkill%20%23drakor%20%23foryo.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/if-wishes-could-kill.jpg"),
    ]

    // MARK: - 5. A Second First Love
    public static let second_first_loveDrama = Drama(
        id: "second-first-love",
        title: "A Second First Love",
        synopsis: "High school sweethearts separated by an orchestrated family tragedy meet again eight years later in a cutthroat corporate merger. Both pretend to have moved on, but their old vows refuse to die.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/second-first-love.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/second-first-love.jpg"),
        genres: ["Romance", "Second Chance", "Drama"],
        tags: ["First Love", "CEO", "Merger"],
        totalEpisodes: 3,
        releaseYear: 2024,
        cast: ["Elena Moore (Architect)", "Lucas Hayes (Group CEO)", "Vivian"],
        isBookmarked: false
    )

    public static let second_first_loveEpisodes: [Episode] = [
        makeEpisode(id: "ep-second-first-love-01", dramaId: "second-first-love", ep: 1, title: "2 Minutes and 30 Seconds of Heart", synopsis: "An emotional reunion in the company elevator tests Elena and Lucas to their limits.", dur: 150.0, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T141631Z/058_7638403708568521997_720x1278_2%20minutes%20and%2030%20seconds%20of%20pure%20heart.%20We%20couldn%E2%80%99t%20cut%20a%20single%20word%20because.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/second-first-love.jpg"),
        makeEpisode(id: "ep-second-first-love-02", dramaId: "second-first-love", ep: 2, title: "A Second First Love Part 1", synopsis: "51-minute full chapter of Elena and Lucas uncovering the secret that tore them apart.", dur: 3082.2, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/3106_7624940643076394247_576x1024_A%20Second%20First%20Love%201%20%23microseries%20%23microdramaepisodes.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/second-first-love.jpg"),
        makeEpisode(id: "ep-second-first-love-03", dramaId: "second-first-love", ep: 3, title: "A Second First Love Part 2", synopsis: "43-minute dramatic conclusion: Lucas risks his family fortune to win Elena back forever.", dur: 2591.833, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/3108_7624948103031934216_480x848_A%20Second%20First%20Love%202%20%23microdramaepisodes%20%23microseries.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/second-first-love.jpg"),
    ]

    // MARK: - 6. They Called Him a Rent-a-Cop
    public static let rent_a_cop_billionaireDrama = Drama(
        id: "rent-a-cop-billionaire",
        title: "They Called Him a Rent-a-Cop",
        synopsis: "Mocked as a mere security guard by the arrogant elites of the Grand Metropolitan Club, former Special Forces operative Jack reveals his authority as the supreme commander protecting the city's wealthiest district.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/rent-a-cop-billionaire.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/rent-a-cop-billionaire.jpg"),
        genres: ["Action", "Billionaire", "Undercover"],
        tags: ["Security Guard", "Special Forces", "Respect"],
        totalEpisodes: 2,
        releaseYear: 2024,
        cast: ["Jack Carter (Security Commander)", "Melissa (Elite Heiress)", "Gordon"],
        isBookmarked: false
    )

    public static let rent_a_cop_billionaireEpisodes: [Episode] = [
        makeEpisode(id: "ep-rent-a-cop-billionaire-01", dramaId: "rent-a-cop-billionaire", ep: 1, title: "Just the Maid Secret", synopsis: "Jack intervenes when an arrogant young heir tries to humiliate the venue staff.", dur: 15.042, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/5355_7635433154920107277_720x1280_They%20called%20her%20%E2%80%9Cjust%20the%20maid%E2%80%9D%E2%80%A6%20until%20she%20opened%20the%20room%20nobody%20else%20cou.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/rent-a-cop-billionaire.jpg"),
        makeEpisode(id: "ep-rent-a-cop-billionaire-02", dramaId: "rent-a-cop-billionaire", ep: 2, title: "Rent-a-Cop Master Feature", synopsis: "56-minute full series cut: Jack takes down the criminal syndicate threatening the entire city.", dur: 3380.4, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/6506_7648513337201888532_576x1024_They%20Called%20Him%20a%20Rent-a-Cop%20Part%202-2%20%282%29%20.%20.%20If%20you%20like%20my%20post%20please%20FOLLOW.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/rent-a-cop-billionaire.jpg"),
    ]

    // MARK: - 7. Dare Me: Campus Secrets
    public static let dare_me_campus_secretsDrama = Drama(
        id: "dare-me-campus-secrets",
        title: "Dare Me: Campus Secrets",
        synopsis: "An intense campus drama of cheer rivalries, secret pacts, and forbidden infatuation between team co-captains and an alluring coach who brings danger to their small town.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/dare-me-campus-secrets.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/dare-me-campus-secrets.jpg"),
        genres: ["Thriller", "Campus", "Drama"],
        tags: ["High School", "Cheerleader", "Secrets"],
        totalEpisodes: 1,
        releaseYear: 2024,
        cast: ["Addy Hanlon (Cheerleader)", "Beth Cassidy (Captain)", "Coach Colette"],
        isBookmarked: false
    )

    public static let dare_me_campus_secretsEpisodes: [Episode] = [
        makeEpisode(id: "ep-dare-me-campus-secrets-01", dramaId: "dare-me-campus-secrets", ep: 1, title: "Season 1 Full Master Feature", synopsis: "52-minute full 1080x1920 Full HD continuous feature following the mystery surrounding Coach Colette's arrival.", dur: 3125.033, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/074_7580832006976572694_1080x1920_Dare%20me%20s1%20episode%201%20full%20episode%20%23dareme%20%23fullepisode%20%23underatedshow%20%23fyp%20%23dont.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/dare-me-campus-secrets.jpg"),
    ]

    // MARK: - 8. The Don's Darling
    public static let the_dons_darlingDrama = Drama(
        id: "the-dons-darling",
        title: "The Don's Darling",
        synopsis: "Framed and captured in a syndicate blood feud, innocent pianist Sienna is held captive by ruthless Don Matteo—who finds himself willing to burn down his own empire to keep her safe.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-dons-darling.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-dons-darling.jpg"),
        genres: ["Mafia", "Dark Romance", "Billionaire"],
        tags: ["Captive", "Mob Boss", "Obsession"],
        totalEpisodes: 3,
        releaseYear: 2024,
        cast: ["Sienna (Concert Pianist)", "Don Matteo (Syndicate Leader)", "Lucian"],
        isBookmarked: false
    )

    public static let the_dons_darlingEpisodes: [Episode] = [
        makeEpisode(id: "ep-the-dons-darling-01", dramaId: "the-dons-darling", ep: 1, title: "Meeting The Don", synopsis: "Sienna wakes up in Don Matteo's fortified villa, learning the price of her brother's betrayal.", dur: 151.267, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/035_7624042124400512264_576x1018_Ep.1%20The%20Don%27s%20Darling%20Disclaimer_%20No%20copyright%20infringement%20intended%20%23thedonsda.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-dons-darling.jpg"),
        makeEpisode(id: "ep-the-dons-darling-02", dramaId: "the-dons-darling", ep: 2, title: "The Syndicate Vow", synopsis: "Don Matteo makes a vow before the five crime families: anyone who touches Sienna dies.", dur: 114.867, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/5883_7621144029413084438_720x1280_The%20Don%27s%20Darling%20EP10%20%F0%9F%8C%9F%20Continue%20the%20story%20here%20%F0%9F%91%89%F0%9F%8F%BB%20%F0%9F%93%B2Click%20the%20link.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-dons-darling.jpg"),
        makeEpisode(id: "ep-the-dons-darling-03", dramaId: "the-dons-darling", ep: 3, title: "The Billionaire Don's Secret Boss", synopsis: "Sienna reveals her own leverage, turning the power dynamics completely upside down.", dur: 362.185, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/4496_7636430008856087816_576x1280_The%20Billionaire%20Don%27s%20Secret%20Boss%20ending%20part%20please%20follow%20like%20share%20comment%20n.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-dons-darling.jpg"),
    ]

    // MARK: - 9. No More Secretary, No More Secret Lover
    public static let no_more_secretaryDrama = Drama(
        id: "no-more-secretary",
        title: "No More Secretary, No More Secret Lover",
        synopsis: "After three years of secret loyalty to arrogant CEO Sean, top secretary Chloe resigns on the spot when his scheming ex returns—only to launch her own rival firm and steal his biggest clients.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/no-more-secretary.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/no-more-secretary.jpg"),
        genres: ["Workplace", "Revenge", "Romance"],
        tags: ["Boss & Secretary", "Glow Up", "Rival"],
        totalEpisodes: 3,
        releaseYear: 2024,
        cast: ["Chloe (Top Secretary / CEO)", "Sean (Group Chairman)", "Isabella"],
        isBookmarked: false
    )

    public static let no_more_secretaryEpisodes: [Episode] = [
        makeEpisode(id: "ep-no-more-secretary-01", dramaId: "no-more-secretary", ep: 1, title: "Resignation and Retaliation", synopsis: "Chloe slams her resignation letter on Sean's mahogany desk before the board meeting.", dur: 34.433, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/048_7649597103739538719_720x1280_No%20More%20Secretary%2C%20No%20More%20Secret%20Lover%2005%20%23dramabox%20%23drama%20%23shortsdrama%20%23shortf.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/no-more-secretary.jpg"),
        makeEpisode(id: "ep-no-more-secretary-02", dramaId: "no-more-secretary", ep: 2, title: "The New Boss", synopsis: "Sean realizes Chloe's value when his new business pitch fails without her preparation.", dur: 44.3, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/050_7649599049624030495_720x1280_No%20More%20Secretary%2C%20No%20More%20Secret%20Lover%2006%20%23dramabox%20%23drama%20%23shortsdrama%20%23shortf.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/no-more-secretary.jpg"),
        makeEpisode(id: "ep-no-more-secretary-03", dramaId: "no-more-secretary", ep: 3, title: "Secret Maid to President", synopsis: "Chloe appears at the international summit as the newly appointed venture president.", dur: 120.875, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260611T120351Z/088_7616205100624760080_720x1280_Student%20president%20by%20day%2C%20his%20secret%20maid%20by%20night%E2%80%94now%20he%27s%20demanding%20more%20tha.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/no-more-secretary.jpg"),
    ]

    // MARK: - 10. Reborn Rookie: Unstoppable
    public static let reborn_rookieDrama = Drama(
        id: "reborn-rookie",
        title: "Reborn Rookie: Unstoppable",
        synopsis: "Betrayed by his partners and pushed off a rooftop, investment banker Jason awakens 10 years earlier on his first day as a junior analyst. Armed with complete knowledge of market crashes, he builds an unbeatable empire.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/reborn-rookie.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/reborn-rookie.jpg"),
        genres: ["Rebirth", "Urban Tycoon", "Revenge"],
        tags: ["Time Travel", "Wall Street", "Dominance"],
        totalEpisodes: 1,
        releaseYear: 2024,
        cast: ["Jason (Analyst / Future Tycoon)", "Elena (Tech Founder)", "Marcus"],
        isBookmarked: false
    )

    public static let reborn_rookieEpisodes: [Episode] = [
        makeEpisode(id: "ep-reborn-rookie-01", dramaId: "reborn-rookie", ep: 1, title: "Full Episode 1 Master Feature", synopsis: "52-minute full continuous feature of Jason using future insights to conquer the financial market from day one.", dur: 3115.9, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/2249_7648988138160835847_576x1022_Reborn%20Rookie%20Full_Episode_01%20%23RebornRookie%20%23copyrightinfringement%20%23rightfulowne.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/reborn-rookie.jpg"),
    ]

    // MARK: - 11. After the Divorce, My Ex Moved Downstairs
    public static let after_the_divorceDrama = Drama(
        id: "after-the-divorce",
        title: "After the Divorce, My Ex Moved Downstairs",
        synopsis: "Thinking divorce would finally set him free, arrogant billionaire Logan signs the papers—only to discover his brilliant ex-wife Maya bought the luxury penthouse directly downstairs.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/after-the-divorce.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/after-the-divorce.jpg"),
        genres: ["Romance", "Divorce", "Billionaire"],
        tags: ["Second Chance", "Neighbors", "Jealous Ex"],
        totalEpisodes: 3,
        releaseYear: 2024,
        cast: ["Maya (Architect Heiress)", "Logan (Billionaire Ex)", "Oliver"],
        isBookmarked: false
    )

    public static let after_the_divorceEpisodes: [Episode] = [
        makeEpisode(id: "ep-after-the-divorce-01", dramaId: "after-the-divorce", ep: 1, title: "Moving In Downstairs", synopsis: "Logan runs into Maya at the lobby elevator, only to learn she now owns half the high-rise.", dur: 33.1, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/040_7629950346986605840_1080x1920_After%20the%20divorce%E2%80%A6%20my%20ex%20moved%20downstairs%20%EF%BD%9C%20EP%2001%20I%20thought%20leaving%20him%20woul.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/after-the-divorce.jpg"),
        makeEpisode(id: "ep-after-the-divorce-02", dramaId: "after-the-divorce", ep: 2, title: "The Billionaire Escort Aftermath", synopsis: "Maya arrives at the city benefit escorted by Logan's primary business rival.", dur: 287.36, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1047_7650130991440432397_720x1280_Ep%203_Part%203%20of%20The%20Billionaire%20Escort.%20Deal%20with%20the%20aftermath%20of%20the%20family%20din.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/after-the-divorce.jpg"),
        makeEpisode(id: "ep-after-the-divorce-03", dramaId: "after-the-divorce", ep: 3, title: "The Haughty CEO Begs", synopsis: "Logan breaks down his pride, begging Maya to give their marriage one more chance.", dur: 93.133, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260612T024747Z/1108_7529474947555675423_576x1024_Love%20After%20Quick%20Marriage_%20The%20Haughty%20CEO%20Now%20Begs%20for%20Affection%20_EPISODE%2072_%20%23.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/after-the-divorce.jpg"),
    ]

    // MARK: - 12. The Cleaner With A Billion-Dollar Secret
    public static let the_cleaner_billion_secretDrama = Drama(
        id: "the-cleaner-billion-secret",
        title: "The Cleaner With A Billion-Dollar Secret",
        synopsis: "Working night shifts as an office cleaner to protect his grandmother, young Lucas discovers a flash drive containing a conspiracy to steal a billion dollars from his father's old company.",
        coverURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-cleaner-billion-secret.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-cleaner-billion-secret.jpg"),
        genres: ["Action", "Mystery", "Billionaire"],
        tags: ["Secret Identity", "Conspiracy", "Family"],
        totalEpisodes: 3,
        releaseYear: 2024,
        cast: ["Lucas (The Cleaner)", "Seraphina (Board Member)", "Director Sterling"],
        isBookmarked: false
    )

    public static let the_cleaner_billion_secretEpisodes: [Episode] = [
        makeEpisode(id: "ep-the-cleaner-billion-secret-01", dramaId: "the-cleaner-billion-secret", ep: 1, title: "The Secret Revealed", synopsis: "While cleaning the CEO's office after hours, Lucas overhears the syndicate's takeover plot.", dur: 122.08, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/021_7468646615230729502_576x1024_EP1%20_%20%E2%9D%A4%EF%B8%8F%E2%80%8D%F0%9F%94%A5NEW-Release%21%20-%E2%80%9CThe%20Cleaner%20With%20A%20Billion-Dollar%20Secret%E2%80%9D.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-cleaner-billion-secret.jpg"),
        makeEpisode(id: "ep-the-cleaner-billion-secret-02", dramaId: "the-cleaner-billion-secret", ep: 2, title: "Forced to Love", synopsis: "Lucas is brought before the board of directors as Seraphina steps in to shield him.", dur: 114.5, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/023_7506075125058407711_576x1024_Episode%201%20_%20%E2%9D%A4%EF%B8%8FMr.Musk%2CI%20am%20with%20your%20nephew%20now-%F0%9F%94%8E%E2%80%9CForced%20to%20Love.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-cleaner-billion-secret.jpg"),
        makeEpisode(id: "ep-the-cleaner-billion-secret-03", dramaId: "the-cleaner-billion-secret", ep: 3, title: "Love and Truth", synopsis: "Lucas reveals his true heritage as the rightful heir to the entire corporate empire.", dur: 236.2, url: "https://huggingface.co/datasets/Orannue/data_vertical/resolve/main/tiktok/20260610T165533Z/032_7477851707653786896_576x1024_%F0%9F%93%BA%20The%20DUBBED%EF%BC%81%E3%80%90Love%20at%20Fifty%20%E3%80%91EP%2001%20%F0%9F%8F%98%20%E2%8F%ACDownload%20the%20FlickReels%20APP.mp4", cover: "https://raw.githubusercontent.com/kurtapexlegends-bot/ykreels-ios/main/covers/the-cleaner-billion-secret.jpg"),
    ]

    public static let allDramas: [Drama] = [
        taming_my_bulliesDrama,\n        contract_marriage_tycoonDrama,\n        janitor_rise_of_primeDrama,\n        if_wishes_could_killDrama,\n        second_first_loveDrama,\n        rent_a_cop_billionaireDrama,\n        dare_me_campus_secretsDrama,\n        the_dons_darlingDrama,\n        no_more_secretaryDrama,\n        reborn_rookieDrama,\n        after_the_divorceDrama,\n        the_cleaner_billion_secretDrama
    ]

    public static let allCatalogItems: [DramaCatalogItem] = [
        DramaCatalogItem(drama: taming_my_bulliesDrama, episodes: taming_my_bulliesEpisodes),\n        DramaCatalogItem(drama: contract_marriage_tycoonDrama, episodes: contract_marriage_tycoonEpisodes),\n        DramaCatalogItem(drama: janitor_rise_of_primeDrama, episodes: janitor_rise_of_primeEpisodes),\n        DramaCatalogItem(drama: if_wishes_could_killDrama, episodes: if_wishes_could_killEpisodes),\n        DramaCatalogItem(drama: second_first_loveDrama, episodes: second_first_loveEpisodes),\n        DramaCatalogItem(drama: rent_a_cop_billionaireDrama, episodes: rent_a_cop_billionaireEpisodes),\n        DramaCatalogItem(drama: dare_me_campus_secretsDrama, episodes: dare_me_campus_secretsEpisodes),\n        DramaCatalogItem(drama: the_dons_darlingDrama, episodes: the_dons_darlingEpisodes),\n        DramaCatalogItem(drama: no_more_secretaryDrama, episodes: no_more_secretaryEpisodes),\n        DramaCatalogItem(drama: reborn_rookieDrama, episodes: reborn_rookieEpisodes),\n        DramaCatalogItem(drama: after_the_divorceDrama, episodes: after_the_divorceEpisodes),\n        DramaCatalogItem(drama: the_cleaner_billion_secretDrama, episodes: the_cleaner_billion_secretEpisodes)
    ]
}
