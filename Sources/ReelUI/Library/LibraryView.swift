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
    @State private var dramaCount: Int = 5
    @State private var episodeCount: Int = 133
    @State private var syncStatus: String = "Live Feed Connected"
    @State private var isSyncing: Bool = false
    private let cacheLimitMB: Double = 250.0
    @State private var activeDrama: Drama = WrongMatchRightCrushData.drama
    @State private var activeEpisodes: [Episode] = WrongMatchRightCrushData.episodes

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    continueWatchingSection
                    storageCacheSection
                    remoteFeedSection
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.bottom, 80)
            }
            .background(ReelTheme.pureBlack)
            .navigationTitle("Library")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                updateCacheSize()
                loadPlaybackProgress()
                reloadCatalogCounts()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dramaCatalogDidUpdate)) { _ in
                reloadCatalogCounts()
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
        if let latest = try? DramaRepository.shared.fetchLatestPlaybackProgress() {
            self.playbackProgress = latest
            if let drama = try? DramaRepository.shared.fetchDrama(id: latest.dramaId) {
                self.activeDrama = drama
            }
            if let eps = try? DramaRepository.shared.fetchEpisodes(dramaId: latest.dramaId), !eps.isEmpty {
                self.activeEpisodes = eps
            }
        } else {
            self.playbackProgress = try? DramaRepository.shared.fetchPlaybackProgress(dramaId: WrongMatchRightCrushData.drama.id)
            self.activeDrama = WrongMatchRightCrushData.drama
            self.activeEpisodes = WrongMatchRightCrushData.episodes
        }
    }

    // MARK: - Continue Watching
    private var continueWatchingSection: some View {
        let epNum = playbackProgress?.lastEpisodeNumber ?? 1
        let ep = activeEpisodes.first(where: { $0.episodeNumber == epNum }) ?? activeEpisodes.first
        let epTitle = ep?.title ?? "Episode \(epNum)"
        let ratio = playbackProgress?.progressRatio ?? 0.0
        let percentStr = playbackProgress?.percentageString ?? "0%"

        return VStack(alignment: .leading, spacing: 10) {
            Text("Continue Watching")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            Button(action: {
                let startIdx = activeEpisodes.firstIndex(where: { $0.episodeNumber == epNum }) ?? max(0, epNum - 1)
                let playhead = playbackProgress?.playheadSeconds ?? 0.0
                PlayerPoolCoordinator.shared.loadEpisodes(activeEpisodes, dramaTitle: activeDrama.title, coverURL: activeDrama.coverURL, startingAt: startIdx, initialSeek: playhead)
                AppNavigationCoordinator.shared.switchToFeed()
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        DramaCoverImage(drama: activeDrama, cornerRadius: ReelTheme.cornerRadiusSmall)
                            .frame(width: 72, height: 96)

                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall))

                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(ReelTheme.sakuraPink)
                    }
                    .frame(width: 72, height: 96)
                    .overlay(
                        RoundedRectangle(cornerRadius: ReelTheme.cornerRadiusSmall)
                            .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(activeDrama.title)
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
            .buttonStyle(.plain)
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

    // MARK: - Remote Drama Catalog Feed
    private var remoteFeedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Drama Catalog Feed")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(dramaCount) Series • \(episodeCount) Episodes")
                            .font(.subheadline)
                            .foregroundColor(ReelTheme.textPrimary)

                        Text(syncStatus)
                            .font(.caption2)
                            .foregroundColor(ReelTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { triggerManualSync() }) {
                        if isSyncing {
                            ProgressView()
                                .tint(ReelTheme.sakuraPink)
                                .scaleEffect(0.8)
                        } else {
                            Text("Check Updates")
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
                    .disabled(isSyncing)
                }
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

    private func reloadCatalogCounts() {
        dramaCount = (try? DramaRepository.shared.fetchTotalDramaCount()) ?? 5
        episodeCount = (try? DramaRepository.shared.fetchTotalEpisodeCount()) ?? 133
    }

    private func triggerManualSync() {
        guard !isSyncing else { return }
        isSyncing = true
        syncStatus = "Checking remote feed..."
        Task {
            let res = await CuratedDramaCatalog.shared.syncFromRemote(force: true)
            switch res {
            case .updated(let d, let e):
                syncStatus = "Updated: \(d) series, \(e) episodes"
            case .notModified:
                syncStatus = "Up to date"
            case .failed(let err):
                syncStatus = "Feed: \(err)"
            }
            reloadCatalogCounts()
            isSyncing = false
        }
    }
}
