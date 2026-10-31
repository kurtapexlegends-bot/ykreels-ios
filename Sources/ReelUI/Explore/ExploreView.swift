import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer
import ReelDatabase

/// Immersive Explore & Drama catalog tab.
/// Features StoryReel/ReelShort standard 160x230 poster cards, Apple glassmorphism,
/// Sakura Pink accents, and instant-play switching.
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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    searchBar
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ExploreSearchResultsView(
                            searchText: searchText,
                            allEpisodes: allEpisodes,
                            selectedDrama: selectedDrama,
                            onSelectDrama: { switchToDrama($0) },
                            onSelectEpisode: { ep in
                                Task {
                                    let drama = try? await CuratedDramaCatalog.shared.getDrama(id: ep.dramaId)
                                    let eps = (try? await CuratedDramaCatalog.shared.getEpisodes(dramaId: ep.dramaId)) ?? [ep]
                                    let targetIdx = eps.firstIndex(where: { $0.id == ep.id }) ?? max(0, ep.episodeNumber - 1)
                                    PlayerPoolCoordinator.shared.loadEpisodes(
                                        eps,
                                        dramaTitle: drama?.title ?? selectedDrama.title,
                                        coverURL: drama?.coverURL ?? selectedDrama.coverURL,
                                        startingAt: targetIdx
                                    )
                                    AppNavigationCoordinator.shared.switchToFeed()
                                }
                            }
                        )
                    } else {
                        featuredHeroCard
                        allDramasShelf
                        genresSection
                        castSection
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.bottom, 80)
            }
            .background(ReelTheme.pureBlack)
            .navigationTitle("Explore")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                await loadCatalog()
                await CuratedDramaCatalog.shared.syncFromRemote()
                await loadCatalog()
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ReelTheme.textSecondary)

            TextField("Search dramas, genres, cast...", text: $searchText)
                .font(.subheadline)
                .foregroundColor(ReelTheme.textPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ReelTheme.textTertiary)
                }
            }
        }
        .padding(12)
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
                DramaCoverImage(drama: featured, cornerRadius: ReelTheme.cornerRadiusLarge)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.3), Color.black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("FEATURED SERIES")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(ReelTheme.sakuraPink)
                            .tracking(1.4)

                        Spacer()

                        Text("\(featured.totalEpisodes) Episodes")
                            .font(.caption2.bold())
                            .foregroundColor(ReelTheme.sakuraMist)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

                    Text(featured.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ReelTheme.textPrimary)
                        .lineLimit(2)

                    Text(featured.synopsis)
                        .font(.caption)
                        .foregroundColor(ReelTheme.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.caption.bold())
                            Text("Watch Now")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(ReelTheme.sakuraPink)
                        .clipShape(Capsule())

                        Text(featured.genresDisplay)
                            .font(.caption)
                            .foregroundColor(ReelTheme.sakuraMist)
                    }
                    .padding(.top, 4)
                }
                .padding(18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusLarge)
                    .strokeBorder(ReelTheme.sakuraPink.opacity(0.35), lineWidth: 0.8)
            )
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    // MARK: - All Dramas Shelf
    private var allDramasShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Series (\(allDramas.count))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.textPrimary)

                Spacer()

                Text("Swipe to explore")
                    .font(.caption)
                    .foregroundColor(ReelTheme.textTertiary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(allDramas) { drama in
                        Button(action: { switchToDrama(drama) }) {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .bottomLeading) {
                                    // Poster Layer
                                    DramaCoverImage(drama: drama, cornerRadius: ReelTheme.cornerRadiusMedium)
                                        .frame(width: 160, height: 230)

                                    // Contrast Vignette at bottom
                                    LinearGradient(
                                        colors: [Color.clear, Color.black.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 80)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium))

                                    // Episode Count Tag
                                    Text("\(drama.totalEpisodes) Eps")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(ReelTheme.sakuraPink)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                                        .padding(10)
                                }
                                .frame(width: 160, height: 230)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium)
                                        .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.6)
                                )

                                Text(drama.title)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(ReelTheme.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 160, alignment: .leading)

                                Text(drama.genresDisplay)
                                    .font(.caption)
                                    .foregroundColor(ReelTheme.textSecondary)
                                    .lineLimit(1)
                                    .frame(width: 160, alignment: .leading)
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
                PlayerPoolCoordinator.shared.loadEpisodes(episodes, dramaTitle: drama.title, coverURL: drama.coverURL, startingAt: 0)
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
    private var allAvailableGenres: [String] {
        var set = Set<String>(), list: [String] = []
        for d in allDramas {
            for g in d.genres where set.insert(g).inserted { list.append(g) }
        }
        return list.isEmpty ? featured.genres : list
    }

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Genres")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allAvailableGenres, id: \.self) { genre in
                        Button(action: { searchText = genre }) {
                            Text(genre)
                                .font(.subheadline)
                                .foregroundColor(ReelTheme.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
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
                .font(.headline).fontWeight(.bold).foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ForEach(featured.cast, id: \.self) { name in
                    Button(action: {
                        searchText = name.components(separatedBy: " (").first ?? name
                    }) {
                        HStack(spacing: 12) {
                            Circle().fill(Color.white.opacity(0.08)).frame(width: 36, height: 36)
                                .overlay(Image(systemName: "person.fill").font(.system(size: 14)).foregroundColor(ReelTheme.sakuraPink))
                            Text(name).font(.subheadline).foregroundColor(ReelTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption2).foregroundColor(ReelTheme.textTertiary)
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
