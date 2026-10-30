import SwiftUI
import ReelCore

/// Frosted glass bottom sheet displaying all 25 episodes in a clean grid.
@MainActor
public struct EpisodeDrawerSheet: View {
    public let episodes: [Episode]
    public let currentEpisodeNumber: Int
    public let onSelectEpisode: (Episode) -> Void

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 10)]

    public init(
        episodes: [Episode],
        currentEpisodeNumber: Int,
        onSelectEpisode: @escaping (Episode) -> Void
    ) {
        self.episodes = episodes
        self.currentEpisodeNumber = currentEpisodeNumber
        self.onSelectEpisode = onSelectEpisode
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(episodes) { ep in
                        Button(action: { onSelectEpisode(ep) }) {
                            episodeCell(ep)
                        }
                    }
                }
                .padding()
            }
            .background(ReelTheme.pureBlack)
            .navigationTitle("Episodes (\(episodes.count))")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private func episodeCell(_ ep: Episode) -> some View {
        let isSelected = ep.episodeNumber == currentEpisodeNumber
        return ZStack {
            RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                .fill(isSelected ? ReelTheme.sakuraPink : Color.white.opacity(0.08))
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                        .strokeBorder(
                            isSelected ? ReelTheme.sakuraMist : ReelTheme.glassBorder,
                            lineWidth: 0.5
                        )
                )

            VStack(spacing: 2) {
                Text("\(ep.episodeNumber)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .black : .white)

                Text(ep.formattedDuration)
                    .font(.system(size: 8.5))
                    .foregroundColor(
                        isSelected ? Color.black.opacity(0.7) : ReelTheme.textSecondary
                    )
            }
        }
    }
}
