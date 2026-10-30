import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer
import ReelDatabase

/// Search results view for Explore tab, showing matched series and episodes.
@MainActor
public struct ExploreSearchResultsView: View {
    public let searchText: String
    public let allEpisodes: [Episode]
    public let selectedDrama: Drama
    public let onSelectDrama: (Drama) -> Void
    public let onSelectEpisode: (Episode) -> Void

    public init(
        searchText: String,
        allEpisodes: [Episode],
        selectedDrama: Drama,
        onSelectDrama: @escaping (Drama) -> Void,
        onSelectEpisode: @escaping (Episode) -> Void
    ) {
        self.searchText = searchText
        self.allEpisodes = allEpisodes
        self.selectedDrama = selectedDrama
        self.onSelectDrama = onSelectDrama
        self.onSelectEpisode = onSelectEpisode
    }

    private var matchedEpisodes: [Episode] {
        let dbEpisodes = (try? DramaRepository.shared.searchEpisodes(query: searchText)) ?? []
        if !dbEpisodes.isEmpty { return dbEpisodes }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return allEpisodes.filter { ep in
            ep.title.lowercased().contains(query) ||
            (ep.synopsis?.lowercased().contains(query) ?? false) ||
            "\(ep.episodeNumber)".contains(query)
        }
    }

    public var body: some View {
        let matchedDramas = (try? DramaRepository.shared.searchDramas(query: searchText)) ?? []
        VStack(alignment: .leading, spacing: 16) {
            if !matchedDramas.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Series Matches (\(matchedDramas.count))")
                        .font(.subheadline).fontWeight(.semibold).foregroundColor(ReelTheme.textPrimary)
                        .padding(.horizontal)

                    ForEach(matchedDramas) { drama in
                        Button(action: { onSelectDrama(drama) }) {
                            HStack(spacing: 12) {
                                AsyncImage(url: drama.coverURL) { phase in
                                    if let img = phase.image {
                                        img.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.white.opacity(0.08)
                                    }
                                }
                                .frame(width: 48, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(drama.title)
                                        .font(.subheadline).fontWeight(.bold).foregroundColor(ReelTheme.textPrimary)
                                    Text(drama.genresDisplay)
                                        .font(.caption2).foregroundColor(ReelTheme.textSecondary)
                                    Text("\(drama.totalEpisodes) Episodes")
                                        .font(.caption2).foregroundColor(ReelTheme.sakuraPink)
                                }
                                Spacer()
                                Image(systemName: "play.circle.fill").foregroundColor(ReelTheme.sakuraPink)
                            }
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))
                            .overlay(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall).strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Episode Matches (\(matchedEpisodes.count))")
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(ReelTheme.textPrimary)
                    .padding(.horizontal)

                if matchedEpisodes.isEmpty && matchedDramas.isEmpty {
                    Text("No matching dramas or episodes found")
                        .font(.caption).foregroundColor(ReelTheme.textSecondary)
                        .padding(.horizontal)
                } else {
                    ForEach(matchedEpisodes) { ep in
                        Button(action: { onSelectEpisode(ep) }) {
                            HStack(spacing: 12) {
                                Text("\(ep.episodeNumber)")
                                    .font(.headline).fontWeight(.bold).foregroundColor(ReelTheme.sakuraPink)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ep.title).font(.subheadline).fontWeight(.semibold).foregroundColor(ReelTheme.textPrimary)
                                    if let synopsis = ep.synopsis {
                                        Text(synopsis).font(.caption2).foregroundColor(ReelTheme.textSecondary).lineLimit(1)
                                    }
                                }
                                Spacer()
                                Text(ep.formattedDuration).font(.caption2).foregroundColor(ReelTheme.textTertiary)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))
                            .overlay(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall).strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
