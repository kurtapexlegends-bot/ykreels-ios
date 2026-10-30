import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer

/// Minimalist Explore & Drama catalog tab.
/// Features Apple glassmorphism, Sakura Pink badges, and high-signal typography.
@MainActor
public struct ExploreView: View {
    @State private var searchText: String = ""
    private let featured = WrongMatchRightCrushData.drama
    private let allEpisodes = WrongMatchRightCrushData.episodes

    public init() {}

    private var filteredEpisodes: [Episode] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return allEpisodes.filter { ep in
            ep.title.lowercased().contains(query) ||
            (ep.synopsis?.lowercased().contains(query) ?? false) ||
            "\(ep.episodeNumber)".contains(query)
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchBar

                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        searchResultsSection
                    } else {
                        featuredHeroCard
                        genresSection
                        castSection
                    }
                }
                .padding(.vertical, 8)
            }
            .background(ReelTheme.pureBlack)
            .navigationTitle("Explore")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(ReelTheme.textSecondary)

            TextField("Search dramas, episodes, cast", text: $searchText)
                .font(.subheadline)
                .foregroundColor(ReelTheme.textPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ReelTheme.textTertiary)
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium)
                .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
        )
        .padding(.horizontal)
    }

    // MARK: - Search Results
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodes (\(filteredEpisodes.count))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            if filteredEpisodes.isEmpty {
                Text("No matching episodes found")
                    .font(.caption)
                    .foregroundColor(ReelTheme.textSecondary)
                    .padding(.horizontal)
            } else {
                ForEach(filteredEpisodes) { ep in
                    Button(action: {
                        PlayerPoolCoordinator.shared.loadEpisodes(allEpisodes, startingAt: ep.episodeNumber - 1)
                    }) {
                        HStack(spacing: 12) {
                            Text("\(ep.episodeNumber)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(ReelTheme.sakuraPink)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(ep.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ReelTheme.textPrimary)

                                if let synopsis = ep.synopsis {
                                    Text(synopsis)
                                        .font(.caption2)
                                        .foregroundColor(ReelTheme.textSecondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            Text(ep.formattedDuration)
                                .font(.caption2)
                                .foregroundColor(ReelTheme.textTertiary)
                        }
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))
                        .overlay(
                            RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                                .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Featured Hero Card
    private var featuredHeroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge)
                .fill(LinearGradient(
                    colors: [ReelTheme.sakuraPink.opacity(0.25), ReelTheme.cardBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge)
                        .strokeBorder(ReelTheme.sakuraPink.opacity(0.3), lineWidth: 0.8)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("FEATURED")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(ReelTheme.sakuraPink)
                    .tracking(1.2)

                Text(featured.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.textPrimary)

                Text(featured.genresDisplay)
                    .font(.caption2)
                    .foregroundColor(ReelTheme.textSecondary)

                Text("\(featured.totalEpisodes) Episodes • Unlocked")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(ReelTheme.sakuraMist)
            }
            .padding()
        }
        .padding(.horizontal)
    }

    // MARK: - Genres Section
    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Genres")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(featured.genres, id: \.self) { genre in
                        Text(genre)
                            .font(.caption)
                            .foregroundColor(ReelTheme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Cast Section
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cast")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(featured.cast, id: \.self) { name in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(ReelTheme.sakuraPink)
                            )

                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(ReelTheme.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
