import SwiftUI
import ReelCore
import ReelDatabase
import ReelEngine
import ReelPlayer
import ReelDownload

/// Minimalist Library tab.
/// Displays active watch progress, offline downloaded episodes, and 250MB LRU disk cache manager.
@MainActor
public struct LibraryView: View {
    @State private var showingClearCacheAlert: Bool = false
    @State private var cacheUsedMB: Double = 0.0
    @State private var playbackProgress: PlaybackProgress?
    private let cacheLimitMB: Double = 250.0
    private let featured = WrongMatchRightCrushData.drama
    private let episodes = WrongMatchRightCrushData.episodes

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    continueWatchingSection
                    storageCacheSection
                }
                .padding(.vertical, 8)
            }
            .background(ReelTheme.pureBlack)
            .navigationTitle("Library")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                updateCacheSize()
                loadPlaybackProgress()
            }
            .alert("Clear Video Cache?", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    try? EpisodeDownloadManager.shared.clearAllCache()
                    updateCacheSize()
                }
            } message: {
                Text("Purges buffered video chunks from local storage.")
            }
        }
    }

    private func updateCacheSize() {
        cacheUsedMB = EpisodeDownloadManager.shared.calculateTotalCacheSizeMB()
    }

    private func loadPlaybackProgress() {
        playbackProgress = try? DramaRepository.shared.fetchPlaybackProgress(dramaId: featured.id)
    }

    // MARK: - Continue Watching
    private var continueWatchingSection: some View {
        let epNum = playbackProgress?.lastEpisodeNumber ?? 1
        let ep = episodes.first(where: { $0.episodeNumber == epNum }) ?? episodes.first
        let epTitle = ep?.title ?? "The Wrong Number"
        let ratio = playbackProgress?.progressRatio ?? 0.0
        let percentStr = playbackProgress?.percentageString ?? "0%"

        return VStack(alignment: .leading, spacing: 10) {
            Text("Continue Watching")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            Button(action: {
                let startIdx = max(0, epNum - 1)
                let playhead = playbackProgress?.playheadSeconds ?? 0.0
                PlayerPoolCoordinator.shared.loadEpisodes(episodes, startingAt: startIdx, initialSeek: playhead)
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 72, height: 96)

                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(ReelTheme.sakuraPink)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(featured.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(ReelTheme.textPrimary)

                        Text("Ep \(epNum) • \(epTitle)")
                            .font(.caption)
                            .foregroundColor(ReelTheme.textSecondary)

                        Spacer()

                        ProgressView(value: ratio)
                            .tint(ReelTheme.sakuraPink)

                        Text("\(percentStr) completed")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(ReelTheme.sakuraMist)
                    }
                    Spacer()
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
        }
    }

    // MARK: - Storage & 250MB LRU Cache Manager
    private var storageCacheSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Storage (250MB Limit)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Video Chunk Cache")
                            .font(.subheadline)
                            .foregroundColor(ReelTheme.textPrimary)

                        Text(String(format: "%.1f MB of %.0f MB used", cacheUsedMB, cacheLimitMB))
                            .font(.caption2)
                            .foregroundColor(ReelTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { showingClearCacheAlert = true }) {
                        Text("Clear")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ReelTheme.sakuraPink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                    }
                }

                ProgressView(value: min(cacheUsedMB / cacheLimitMB, 1.0))
                    .tint(ReelTheme.sakuraPink)
            }
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusMedium)
                    .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
            )
            .padding(.horizontal)
        }
    }
}
