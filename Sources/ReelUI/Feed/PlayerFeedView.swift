import SwiftUI
import AVKit
import ReelCore
import ReelDatabase
import ReelEngine
import ReelPlayer

/// Ultra-minimalist vertical 9:16 short-drama reel player feed.
/// Features Apple glassmorphism, Soft Pastel Sakura Pink accents,
/// right-edge vertical action stack, and an auto-hiding glass HUD.
@MainActor
public struct PlayerFeedView: View {
    @StateObject private var coordinator = PlayerPoolCoordinator.shared
    @State private var showingEpisodeDrawer: Bool = false
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var showHeartAnimation: Bool = false
    @State private var isHUDVisible: Bool = true
    @State private var autoHideTask: Task<Void, Never>?
    @State private var isScrubbing: Bool = false
    @State private var scrubRatio: Double = 0.0

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ReelTheme.pureBlack

                // MARK: - Video Layer (Edge-to-Edge Full Screen)
                if let player = coordinator.activePlayer {
                    VideoPlayer(player: player)
                        .disabled(true)
                        .aspectRatio(ReelTheme.verticalReelAspectRatio, contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    ProgressView()
                        .tint(ReelTheme.sakuraPink)
                }

                // MARK: - Glassmorphism HUD Overlays
                if isHUDVisible {
                    VStack(alignment: .leading, spacing: 0) {
                        topGlassBar
                        Spacer()
                        bottomGlassHUD
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }

                // MARK: - Double-Tap Heart Burst Animation
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(ReelTheme.sakuraPink)
                        .shadow(color: ReelTheme.sakuraPink.opacity(0.8), radius: 20)
                        .scaleEffect(showHeartAnimation ? 1.15 : 0.6)
                        .opacity(showHeartAnimation ? 1.0 : 0.0)
                        .animation(ReelTheme.butterSpring, value: showHeartAnimation)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                toggleHUDVisibility()
            }
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    triggerDoubleTapLike()
                }
            )
            .gesture(
                DragGesture(minimumDistance: 35)
                    .onEnded { handleVerticalSwipe($0) }
            )
        }
        .ignoresSafeArea()
        .task { loadInitialEpisodes() }
        .sheet(isPresented: $showingEpisodeDrawer) { episodeDrawerSheet }
    }

    // MARK: - Top Glass Bar
    private var topGlassBar: some View {
        HStack(spacing: 12) {
            Text(currentDramaTitle)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ReelTheme.textPrimary)
                .lineLimit(1)
                .shadow(color: Color.black.opacity(0.6), radius: 4, y: 1)

            if let current = coordinator.currentEpisode {
                Text("Ep \(current.episodeNumber) / \(max(1, coordinator.currentEpisodes.count))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.sakuraPink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }

            Spacer()

            Button(action: cyclePlaybackSpeed) {
                Text(String(format: "%.2fx", coordinator.playbackRate))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
    }

    // MARK: - Bottom Glass HUD
    private var bottomGlassHUD: some View {
        VStack(spacing: 14) {
            HStack(alignment: .bottom, spacing: 16) {
                // Left: Episode Info & Progress
                VStack(alignment: .leading, spacing: 6) {
                    if let current = coordinator.currentEpisode {
                        Text(current.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ReelTheme.textPrimary)
                            .lineLimit(2)
                            .shadow(color: Color.black.opacity(0.8), radius: 6, y: 2)

                        HStack(spacing: 8) {
                            Text(formattedTimeProgress)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(ReelTheme.textSecondary)

                            Text("•")
                                .font(.caption)
                                .foregroundColor(ReelTheme.textTertiary)

                            Text("Vertical Reel")
                                .font(.caption)
                                .foregroundColor(ReelTheme.sakuraMist)
                        }
                    }
                }

                Spacer(minLength: 12)

                // Right: StoryReel Vertical Action Column
                VStack(spacing: 16) {
                    glassActionButton(
                        systemImage: isLiked ? "heart.fill" : "heart",
                        label: isLiked ? "Liked" : "Like",
                        tint: isLiked ? ReelTheme.sakuraPink : .white,
                        action: { isLiked.toggle() }
                    )

                    glassActionButton(
                        systemImage: isBookmarked ? "bookmark.fill" : "bookmark",
                        label: isBookmarked ? "Saved" : "Save",
                        tint: isBookmarked ? ReelTheme.sakuraPink : .white,
                        action: { isBookmarked.toggle() }
                    )

                    glassActionButton(
                        systemImage: "rectangle.stack.fill",
                        label: "Episodes",
                        tint: .white,
                        action: { showingEpisodeDrawer = true }
                    )

                    glassActionButton(
                        systemImage: coordinator.isPlaying ? "pause.fill" : "play.fill",
                        label: coordinator.isPlaying ? "Pause" : "Play",
                        tint: .white,
                        action: { coordinator.togglePlayPause() }
                    )
                }
            }
            .padding(.horizontal, 16)

            scrubBar
        }
        .padding(.bottom, 68)
    }

    // MARK: - Interactive Scrub Bar
    private var scrubBar: some View {
        GeometryReader { scrubGeo in
            let playheadRatio: CGFloat = {
                guard coordinator.totalDuration > 0,
                      coordinator.totalDuration.isFinite,
                      coordinator.currentPlayhead.isFinite else { return 0 }
                return max(0, min(CGFloat(coordinator.currentPlayhead / coordinator.totalDuration), 1.0))
            }()
            let displayRatio = isScrubbing ? CGFloat(scrubRatio) : playheadRatio

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 4)

                Capsule()
                    .fill(ReelTheme.sakuraPink)
                    .frame(width: max(4, scrubGeo.size.width * displayRatio), height: 4)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard coordinator.totalDuration > 0, coordinator.totalDuration.isFinite else { return }
                        isScrubbing = true
                        scrubRatio = max(0, min(Double(value.location.x / scrubGeo.size.width), 1.0))
                        scheduleAutoHide()
                    }
                    .onEnded { value in
                        guard coordinator.totalDuration > 0, coordinator.totalDuration.isFinite else {
                            isScrubbing = false
                            return
                        }
                        let finalRatio = max(0, min(Double(value.location.x / scrubGeo.size.width), 1.0))
                        coordinator.seek(to: finalRatio * coordinator.totalDuration)
                        isScrubbing = false
                        scheduleAutoHide()
                    }
            )
        }
        .frame(height: 16)
        .padding(.horizontal, 16)
    }

    // MARK: - Glass Action Button Helper
    private func glassActionButton(systemImage: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            scheduleAutoHide()
            action()
        }) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 46, height: 46)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                    .shadow(color: Color.black.opacity(0.4), radius: 6, y: 2)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(ReelTheme.textPrimary)
                    .shadow(color: Color.black.opacity(0.6), radius: 2)
            }
        }
        .buttonStyle(.plain)
    }

    private var formattedTimeProgress: String {
        let cur = isScrubbing ? (scrubRatio * coordinator.totalDuration) : coordinator.currentPlayhead
        let tot = coordinator.totalDuration
        let currentSeconds = (cur.isFinite && !cur.isNaN && cur >= 0) ? Int(cur) : 0
        let totalSeconds = (tot.isFinite && !tot.isNaN && tot >= 0) ? Int(tot) : 0
        return String(format: "%d:%02d / %d:%02d", currentSeconds / 60, currentSeconds % 60, totalSeconds / 60, totalSeconds % 60)
    }

    private var currentDramaTitle: String {
        coordinator.currentDramaTitle
    }

    // MARK: - Gestures & Interactions
    private func handleVerticalSwipe(_ value: DragGesture.Value) {
        let vertical = value.translation.height
        let horizontal = value.translation.width
        guard abs(vertical) > abs(horizontal) else { return }

        if vertical < -50 {
            withAnimation(ReelTheme.butterSpring) { coordinator.advanceToNextEpisode() }
            scheduleAutoHide()
        } else if vertical > 50 {
            withAnimation(ReelTheme.butterSpring) { coordinator.returnToPreviousEpisode() }
            scheduleAutoHide()
        }
    }

    private func toggleHUDVisibility() {
        withAnimation(ReelTheme.butterSpring) { isHUDVisible.toggle() }
        if isHUDVisible { scheduleAutoHide() }
    }

    private func scheduleAutoHide() {
        autoHideTask?.cancel()
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(ReelTheme.butterSpring) { isHUDVisible = false }
        }
    }

    private func triggerDoubleTapLike() {
        isLiked = true
        showHeartAnimation = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            showHeartAnimation = false
        }
    }

    private func cyclePlaybackSpeed() {
        scheduleAutoHide()
        let rates: [Float] = [1.0, 1.25, 1.5, 2.0]
        let nextIndex = ((rates.firstIndex(of: coordinator.playbackRate) ?? 0) + 1) % rates.count
        coordinator.setPlaybackRate(rates[nextIndex])
    }

    private func loadInitialEpisodes() {
        Task { @MainActor in
            coordinator.onProgressUpdate = { episode, playhead, duration in
                Task { @MainActor in
                    let progress = PlaybackProgress(
                        dramaId: episode.dramaId,
                        lastEpisodeId: episode.id,
                        lastEpisodeNumber: episode.episodeNumber,
                        playheadSeconds: playhead,
                        durationSeconds: duration,
                        isCompleted: duration > 0 && playhead >= (duration - 1.0)
                    )
                    try? DramaRepository.shared.upsertPlaybackProgress(progress)
                }
            }

            guard coordinator.currentEpisodes.isEmpty else { return }

            let initialDrama = (try? await CuratedDramaCatalog.shared.getFeaturedDrama()) ?? WrongMatchRightCrushData.drama
            let eps = (try? await CuratedDramaCatalog.shared.getEpisodes(dramaId: initialDrama.id)) ?? WrongMatchRightCrushData.episodes
            coordinator.loadEpisodes(eps, dramaTitle: initialDrama.title, startingAt: 0)
            scheduleAutoHide()

            Task(priority: .utility) {
                await CuratedDramaCatalog.shared.syncFromRemote()
            }
        }
    }

    // MARK: - Episode Drawer Sheet
    private var episodeDrawerSheet: some View {
        EpisodeDrawerSheet(
            episodes: coordinator.currentEpisodes,
            currentEpisodeNumber: coordinator.currentEpisode?.episodeNumber ?? 1,
            onSelectEpisode: { ep in
                showingEpisodeDrawer = false
                let targetIdx = coordinator.currentEpisodes.firstIndex(where: { $0.id == ep.id }) ?? max(0, ep.episodeNumber - 1)
                coordinator.loadEpisodes(coordinator.currentEpisodes, dramaTitle: coordinator.currentDramaTitle, startingAt: targetIdx)
                scheduleAutoHide()
            }
        )
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}
