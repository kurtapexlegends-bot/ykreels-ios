import Foundation
import ReelCore

/// Pre-bundled curated dataset for the flagship launch drama:
/// "Wrong Match, Right Crush" (All 25 episodes).
public enum WrongMatchRightCrushData {
    public static let dramaId = "drama-wrong-match-right-crush"

    public static let drama = Drama(
        id: dramaId,
        title: "Wrong Match, Right Crush",
        synopsis: "College freshman Nora intends to message her long-time crush, Theo—the charming basketball captain—but accidentally adds Beckett, the campus playboy, instead. After three months of secret late-night romance, Beckett shatters her heart by publicly choosing cheer captain Chloe. As Chloe's bullying escalates, Theo steps in to protect Nora, igniting a genuine love story. But when Beckett realizes Nora's messages were meant for Theo all along, he wages an obsessive campaign to win her back.",
        coverURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/wrong-match-right-crush/cover.jpg"),
        bannerURL: URL(string: "https://raw.githubusercontent.com/ykreels/assets/main/dramas/wrong-match-right-crush/banner.jpg"),
        genres: ["Romance", "College Drama", "Coming-of-Age", "Friends to Lovers"],
        tags: ["Campus", "Basketball Star", "Mistaken Identity", "Love Triangle", "Drama"],
        totalEpisodes: 25,
        releaseYear: 2024,
        cast: ["Nora (Lead)", "Theo (Basketball Captain)", "Beckett (Playboy)", "Chloe (Cheer Captain)"],
        isBookmarked: false
    )

    private static func episodeStream(number: Int) -> [StreamSource] {
        let epFormatted = String(format: "%02d", number)
        let primaryHLS = URL(string: "https://stream.ykreels.internal/dramas/wmrc/ep\(epFormatted)/index.m3u8")!
        let fallbackMP4 = URL(string: "https://stream.ykreels.internal/dramas/wmrc/ep\(epFormatted)/1080p.mp4")!
        return [
            StreamSource(id: "hls-\(number)", url: primaryHLS, format: .hls, quality: .fhd1080p, isDefault: true),
            StreamSource(id: "mp4-\(number)", url: fallbackMP4, format: .mp4, quality: .hd720p, isDefault: false)
        ]
    }

    public static let episodes: [Episode] = [
        Episode(
            id: "ep-wmrc-01",
            dramaId: dramaId,
            episodeNumber: 1,
            title: "The Wrong Number",
            synopsis: "Nora attempts to text basketball star Theo, but accidentally contacts campus playboy Beckett.",
            durationSeconds: 105,
            streamSources: episodeStream(number: 1)
        ),
        Episode(
            id: "ep-wmrc-02",
            dramaId: dramaId,
            episodeNumber: 2,
            title: "Three Months in Secret",
            synopsis: "Late-night banter turns into deep emotional vulnerability as Nora believes she is talking to Theo.",
            durationSeconds: 90,
            streamSources: episodeStream(number: 2)
        ),
        Episode(
            id: "ep-wmrc-03",
            dramaId: dramaId,
            episodeNumber: 3,
            title: "The Cheerleader's Arrival",
            synopsis: "Beckett chooses Chloe at the varsity bonfire, leaving Nora devastated in the crowd.",
            durationSeconds: 110,
            streamSources: episodeStream(number: 3)
        ),
        Episode(
            id: "ep-wmrc-04",
            dramaId: dramaId,
            episodeNumber: 4,
            title: "Heartbreak in the Hallway",
            synopsis: "Chloe confronts Nora, mocking her for thinking someone like Beckett could ever care.",
            durationSeconds: 95,
            streamSources: episodeStream(number: 4)
        ),
        Episode(
            id: "ep-wmrc-05",
            dramaId: dramaId,
            episodeNumber: 5,
            title: "A Knight on the Court",
            synopsis: "When Chloe spills coffee over Nora's notes, Theo steps in and publicly defends her.",
            durationSeconds: 100,
            streamSources: episodeStream(number: 5)
        ),
        Episode(
            id: "ep-wmrc-06",
            dramaId: dramaId,
            episodeNumber: 6,
            title: "The Study Session",
            synopsis: "Theo invites Nora to tutor him in history, sparking a natural, easy chemistry.",
            durationSeconds: 90,
            streamSources: episodeStream(number: 6)
        ),
        Episode(
            id: "ep-wmrc-07",
            dramaId: dramaId,
            episodeNumber: 7,
            title: "The Locker Room Gossip",
            synopsis: "Beckett overhears Theo talking about Nora and feels an inexplicable surge of possessiveness.",
            durationSeconds: 105,
            streamSources: episodeStream(number: 7)
        ),
        Episode(
            id: "ep-wmrc-08",
            dramaId: dramaId,
            episodeNumber: 8,
            title: "Rainy Day Umbrella",
            synopsis: "Trapped in a storm after class, Theo shares his jacket and walks Nora home.",
            durationSeconds: 85,
            streamSources: episodeStream(number: 8)
        ),
        Episode(
            id: "ep-wmrc-09",
            dramaId: dramaId,
            episodeNumber: 9,
            title: "Chloe's Prank",
            synopsis: "Chloe locks Nora in the equipment room before the homecoming prep meeting.",
            durationSeconds: 115,
            streamSources: episodeStream(number: 9)
        ),
        Episode(
            id: "ep-wmrc-10",
            dramaId: dramaId,
            episodeNumber: 10,
            title: "Rescue and Comfort",
            synopsis: "Theo breaks the latch to rescue Nora and confronts Chloe, warning her never to touch Nora again.",
            durationSeconds: 100,
            streamSources: episodeStream(number: 10)
        ),
        Episode(
            id: "ep-wmrc-11",
            dramaId: dramaId,
            episodeNumber: 11,
            title: "The Truth Unveiled",
            synopsis: "Beckett catches a glimpse of Nora's phone screen and realizes she was his secret late-night text girl.",
            durationSeconds: 110,
            streamSources: episodeStream(number: 11)
        ),
        Episode(
            id: "ep-wmrc-12",
            dramaId: dramaId,
            episodeNumber: 12,
            title: "Beckett's Regret",
            synopsis: "Beckett abruptly dumps Chloe and tracks down Nora, begging for another chance.",
            durationSeconds: 95,
            streamSources: episodeStream(number: 12)
        ),
        Episode(
            id: "ep-wmrc-13",
            dramaId: dramaId,
            episodeNumber: 13,
            title: "Too Late",
            synopsis: "Nora tells Beckett that words on a screen meant nothing compared to Theo's real actions.",
            durationSeconds: 100,
            streamSources: episodeStream(number: 13)
        ),
        Episode(
            id: "ep-wmrc-14",
            dramaId: dramaId,
            episodeNumber: 14,
            title: "Basketball Championship",
            synopsis: "Beckett and Theo face intense tension on the court during the championship game.",
            durationSeconds: 120,
            streamSources: episodeStream(number: 14)
        ),
        Episode(
            id: "ep-wmrc-15",
            dramaId: dramaId,
            episodeNumber: 15,
            title: "The Winning Shot",
            synopsis: "Theo scores the game-winner and runs straight to the stands to hug Nora in front of the entire arena.",
            durationSeconds: 105,
            streamSources: episodeStream(number: 15)
        ),
        Episode(
            id: "ep-wmrc-16",
            dramaId: dramaId,
            episodeNumber: 16,
            title: "Chloe's Revenge Plot",
            synopsis: "Humiliated by Beckett's rejection, Chloe conspires to leak Nora's private text logs.",
            durationSeconds: 110,
            streamSources: episodeStream(number: 16)
        ),
        Episode(
            id: "ep-wmrc-17",
            dramaId: dramaId,
            episodeNumber: 17,
            title: "The Leak Goes Wrong",
            synopsis: "Chloe's scheme backfires when the student body sees how genuine Nora was and how manipulative Chloe acted.",
            durationSeconds: 95,
            streamSources: episodeStream(number: 17)
        ),
        Episode(
            id: "ep-wmrc-18",
            dramaId: dramaId,
            episodeNumber: 18,
            title: "Late Night Confession",
            synopsis: "On the campus observation roof, Theo confesses that he has liked Nora since freshman orientation.",
            durationSeconds: 110,
            streamSources: episodeStream(number: 18)
        ),
        Episode(
            id: "ep-wmrc-19",
            dramaId: dramaId,
            episodeNumber: 19,
            title: "The First Kiss",
            synopsis: "Nora and Theo share their first kiss under the city lights, sealing their relationship.",
            durationSeconds: 100,
            streamSources: episodeStream(number: 19)
        ),
        Episode(
            id: "ep-wmrc-20",
            dramaId: dramaId,
            episodeNumber: 20,
            title: "Beckett's Desperation",
            synopsis: "Beckett corners Nora in the library, desperately trying to prove he has changed.",
            durationSeconds: 105,
            streamSources: episodeStream(number: 20)
        ),
        Episode(
            id: "ep-wmrc-21",
            dramaId: dramaId,
            episodeNumber: 21,
            title: "Theo Steps In",
            synopsis: "Theo arrives and warns Beckett to respect Nora's boundaries once and for all.",
            durationSeconds: 90,
            streamSources: episodeStream(number: 21)
        ),
        Episode(
            id: "ep-wmrc-22",
            dramaId: dramaId,
            episodeNumber: 22,
            title: "The Exchange Program",
            synopsis: "Facing academic suspension and personal disgrace, Beckett accepts a sudden transfer overseas.",
            durationSeconds: 95,
            streamSources: episodeStream(number: 22)
        ),
        Episode(
            id: "ep-wmrc-23",
            dramaId: dramaId,
            episodeNumber: 23,
            title: "The Ominous Note",
            synopsis: "Before boarding his flight, Beckett leaves a sealed letter for Nora with a cryptic warning.",
            durationSeconds: 100,
            streamSources: episodeStream(number: 23)
        ),
        Episode(
            id: "ep-wmrc-24",
            dramaId: dramaId,
            episodeNumber: 24,
            title: "Together Against the Storm",
            synopsis: "Nora hands the letter to Theo unopened, choosing complete trust over unresolved ghosts.",
            durationSeconds: 105,
            streamSources: episodeStream(number: 24)
        ),
        Episode(
            id: "ep-wmrc-25",
            dramaId: dramaId,
            episodeNumber: 25,
            title: "Right Match, Right Here",
            synopsis: "At the end-of-year campus gala, Nora and Theo celebrate their love, proving that mistakes lead to destiny.",
            durationSeconds: 130,
            streamSources: episodeStream(number: 25)
        )
    ]
}
