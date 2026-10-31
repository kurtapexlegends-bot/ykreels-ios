import SwiftUI
import ReelCore

/// Frosted glass bottom sheet displaying all episodes of the active drama.
/// Features Sakura Pink accent, True Black OLED styling, and auto-scroll to the current episode.
@MainActor
public struct EpisodeDrawerSheet: View {
    public let episodes: [Episode]
    public let currentEpisodeNumber: Int
    public let dramaTitle: String
    public let onSelectEpisode: (Episode) -> Void

    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 58, maximum: 74), spacing: 10)]

    public init(
        episodes: [Episode],
        currentEpisodeNumber: Int,
        dramaTitle: String = "",
        onSelectEpisode: @escaping (Episode) -> Void
    ) {
        self.episodes = episodes
        self.currentEpisodeNumber = currentEpisodeNumber
        self.dramaTitle = dramaTitle
        self.onSelectEpisode = onSelectEpisode
    }

    public var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if !dramaTitle.isEmpty {
                            HStack(alignment: .center, spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dramaTitle)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(ReelTheme.textPrimary)
                                        .lineLimit(1)

                                    HStack(spacing: 6) {
                                        Text("\(episodes.count) Episodes")
                                            .font(.caption.bold())
                                            .foregroundColor(ReelTheme.sakuraPink)

                                        Text("•")
                                            .font(.caption2)
                                            .foregroundColor(ReelTheme.textTertiary)

                                        Text("100% Free • All Unlocked")
                                            .font(.caption2.bold())
                                            .foregroundColor(ReelTheme.sakuraMist)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        }

                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(episodes) { ep in
                                Button(action: { onSelectEpisode(ep) }) {
                                    episodeCell(ep)
                                }
                                .buttonStyle(.plain)
                                .id(ep.episodeNumber)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
                .background(ReelTheme.pureBlack)
                .onAppear {
                    proxy.scrollTo(currentEpisodeNumber, anchor: .center)
                }
            }
            .navigationTitle("Select Episode")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ReelTheme.textSecondary)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func episodeCell(_ ep: Episode) -> some View {
        let isSelected = ep.episodeNumber == currentEpisodeNumber
        return ZStack {
            RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                .fill(isSelected ? ReelTheme.sakuraPink : Color.white.opacity(0.08))
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                        .strokeBorder(
                            isSelected ? ReelTheme.sakuraMist : ReelTheme.glassBorder,
                            lineWidth: isSelected ? 1.5 : 0.5
                        )
                )

            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    if isSelected {
                        Image(systemName: "play.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Text("\(ep.episodeNumber)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isSelected ? .black : .white)
                }

                Text(ep.formattedDuration)
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundColor(
                        isSelected ? Color.black.opacity(0.75) : ReelTheme.textSecondary
                    )
            }
        }
    }
}
