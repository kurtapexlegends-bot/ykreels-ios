import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer
import ReelDatabase

/// Minimalist Explore & Drama catalog tab.
/// Features Apple glassmorphism, Sakura Pink badges, and high-signal typography.
@MainActor
public struct ExploreView: View {
    @State private var searchText: String = ""
    @State private var selectedDrama: Drama = WrongMatchRightCrushData.drama
    @State private var allDramas: [Drama] = [WrongMatchRightCrushData.drama]
    @State private var allEpisodes: [Episode] = WrongMatchRightCrushData.episodes
    private var featured: Drama { selectedDrama }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchBar
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ExploreSearchResultsView(
                            searchText: searchText,
                            allEpisodes: allEpisodes,
                            selectedDrama: selectedDrama,
                            onSelectDrama: { switchToDrama($0) },
                            onSelectEpisode: { ep in
                                PlayerPoolCoordinator.shared.loadEpisodes(
                                    allEpisodes,
                                    dramaTitle: selectedDrama.title,
                                    startingAt: max(0, ep.episodeNumber - 1)
                                )
                                AppNavigationCoordinator.shared.switchToFeed()
                            }
                        )
                    } else {
                        featuredHeroCard
                        allDramasShelf
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
            .task {
                await loadCatalog()
                await CuratedDramaCatalog.shared.syncFromRemote()
            }
            .refreshable {
                await CuratedDramaCatalog.shared.syncFromRemote(force: true)
                await loadCatalog()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dramaCatalogDidUpdate)) { _ in
                Task { await loadCatalog() }
            }
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

    // MARK: - Featured Hero Card
    private var featuredHeroCard: some View {
        Button(action: { switchToDrama(featured) }) {
            ZStack(alignment: .bottomLeading) {
                if let bannerURL = featured.bannerURL ?? featured.coverURL {
                    AsyncImage(url: bannerURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill).frame(height: 200).clipped()
                        case .failure:
                            heroFallbackBackground
                        case .empty:
                            ZStack { heroFallbackBackground; ProgressView().tint(ReelTheme.sakuraPink) }
                        @unknown default:
                            heroFallbackBackground
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge))
                } else {
                    heroFallbackBackground
                }

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("FEATURED")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(ReelTheme.sakuraPink)
                            .tracking(1.2)
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundColor(ReelTheme.sakuraPink)
                    }

                    Text(featured.title)
                        .font(.title3).fontWeight(.bold).foregroundColor(ReelTheme.textPrimary)

                    Text(featured.genresDisplay)
                        .font(.caption2).foregroundColor(ReelTheme.textSecondary)

                    Text("\(featured.totalEpisodes) Episodes • Tap to Play")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(ReelTheme.sakuraMist)
                }
                .padding()
            }
            .overlay(
                RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge)
                    .strokeBorder(ReelTheme.sakuraPink.opacity(0.3), lineWidth: 0.8)
            )
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    private var heroFallbackBackground: some View {
        RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge)
            .fill(LinearGradient(
                colors: [ReelTheme.sakuraPink.opacity(0.25), ReelTheme.cardBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 200)
    }

    // MARK: - All Dramas Shelf
    private var allDramasShelf: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Series (\(allDramas.count))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allDramas) { drama in
                        Button(action: { switchToDrama(drama) }) {
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .bottomLeading) {
                                    AsyncImage(url: drama.coverURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        case .failure:
                                            ZStack {
                                                Color.white.opacity(0.06)
                                                Image(systemName: "film")
                                                    .font(.caption)
                                                    .foregroundColor(ReelTheme.sakuraPink.opacity(0.7))
                                            }
                                        case .empty:
                                            ZStack {
                                                Color.white.opacity(0.04)
                                                ProgressView().tint(ReelTheme.sakuraPink).scaleEffect(0.6)
                                            }
                                        @unknown default:
                                            Color.white.opacity(0.06)
                                        }
                                    }
                                    .frame(width: 125, height: 175)
                                    .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))

                                    LinearGradient(
                                        colors: [Color.clear, Color.black.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))

                                    Text("\(drama.totalEpisodes) Eps")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(ReelTheme.sakuraPink)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .padding(8)
                                }
                                .frame(width: 125, height: 175)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                                        .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
                                )

                                Text(drama.title)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(ReelTheme.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 125, alignment: .leading)

                                Text(drama.genresDisplay)
                                    .font(.system(size: 9))
                                    .foregroundColor(ReelTheme.textTertiary)
                                    .lineLimit(1)
                                    .frame(width: 125, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func switchToDrama(_ drama: Drama) {
        selectedDrama = drama
        Task {
            if let episodes = try? await CuratedDramaCatalog.shared.getEpisodes(dramaId: drama.id), !episodes.isEmpty {
                self.allEpisodes = episodes
                PlayerPoolCoordinator.shared.loadEpisodes(episodes, dramaTitle: drama.title, startingAt: 0)
                AppNavigationCoordinator.shared.switchToFeed()
            }
        }
    }

    private func loadCatalog() async {
        if let dramas = try? await CuratedDramaCatalog.shared.getAllDramas(), !dramas.isEmpty {
            self.allDramas = dramas
            if !dramas.contains(where: { $0.id == selectedDrama.id }), let first = dramas.first {
                self.selectedDrama = first
            }
        }
        if let episodes = try? await CuratedDramaCatalog.shared.getEpisodes(dramaId: selectedDrama.id), !episodes.isEmpty {
            self.allEpisodes = episodes
        }
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
