import SwiftUI
import AVKit
import ReelCore
import ReelDatabase
import ReelEngine
import ReelPlayer

/// Ultra-minimalist vertical 9:16 short-drama reel player feed.
/// Features Apple glassmorphism, Soft Pastel Sakura Pink accents,
/// butter-smooth spring physics, and an auto-hiding glass HUD.
@MainActor
public struct PlayerFeedView: View {
    @StateObject private var coordinator = PlayerPoolCoordinator.shared
    @State private var episodes: [Episode] = []
    @State private var showingEpisodeDrawer: Bool = false
    @State private var isLiked: Bool = false
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
                    .ignoresSafeArea()

                // MARK: - Video Layer
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
                        .font(.system(size: 72))
                        .foregroundColor(ReelTheme.sakuraPink)
                        .shadow(color: ReelTheme.sakuraPink.opacity(0.6), radius: 16)
                        .scaleEffect(showHeartAnimation ? 1.15 : 0.6)
                        .opacity(showHeartAnimation ? 1.0 : 0.0)
                        .animation(ReelTheme.butterSpring, value: showHeartAnimation)
                }
            }
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
        .task { loadInitialEpisodes() }
        .sheet(isPresented: $showingEpisodeDrawer) { episodeDrawerSheet }
    }

    // MARK: - Top Glass Bar
    private var topGlassBar: some View {
        let activeEpisodes = coordinator.currentEpisodes.isEmpty ? episodes : coordinator.currentEpisodes
        return HStack(spacing: 12) {
            Text(currentDramaTitle)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ReelTheme.textPrimary)
                .lineLimit(1)

            if let current = coordinator.currentEpisode {
                Text("\(current.episodeNumber) / \(activeEpisodes.count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.sakuraPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }

            Spacer()

            Button(action: cyclePlaybackSpeed) {
                Text(String(format: "%.2fx", coordinator.playbackRate))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Bottom Glass HUD
    private var bottomGlassHUD: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    if let current = coordinator.currentEpisode {
                        Text(current.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(ReelTheme.textPrimary)

                        Text(formattedTimeProgress)
                            .font(.caption2)
                            .foregroundColor(ReelTheme.textSecondary)
                    }
                }

                Spacer()

                HStack(spacing: 10) {
                    glassActionButton(
                        systemImage: isLiked ? "heart.fill" : "heart",
                        tint: isLiked ? ReelTheme.sakuraPink : .white,
                        action: { isLiked.toggle() }
                    )

                    glassActionButton(
                        systemImage: "list.number",
                        tint: .white,
                        action: { showingEpisodeDrawer = true }
                    )

                    glassActionButton(
                        systemImage: coordinator.isPlaying ? "pause.fill" : "play.fill",
                        tint: .white,
                        action: { coordinator.togglePlayPause() }
                    )
                }
            }
            .padding(.horizontal, 16)

            scrubBar
        }
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
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 3)

                Capsule()
                    .fill(ReelTheme.sakuraPink)
                    .frame(width: scrubGeo.size.width * displayRatio, height: 3)
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
        .frame(height: 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Glass Action Button Helper
    private func glassActionButton(systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            scheduleAutoHide()
            action()
        }) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
        }
    }

    private var formattedTimeProgress: String {
        let cur = coordinator.currentPlayhead
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
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(ReelTheme.butterSpring) { isHUDVisible = false }
        }
    }

    private func triggerDoubleTapLike() {
        isLiked = true
        showHeartAnimation = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
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
            let initialDrama = (try? await CuratedDramaCatalog.shared.getFeaturedDrama()) ?? WrongMatchRightCrushData.drama
            let eps = (try? await CuratedDramaCatalog.shared.getEpisodes(dramaId: initialDrama.id)) ?? WrongMatchRightCrushData.episodes
            self.episodes = eps

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
            coordinator.loadEpisodes(eps, dramaTitle: initialDrama.title, startingAt: 0)
            scheduleAutoHide()

            Task(priority: .utility) {
                await CuratedDramaCatalog.shared.syncFromRemote()
            }
        }
    }

    // MARK: - Episode Drawer Sheet
    private var episodeDrawerSheet: some View {
        let activeEpisodes = coordinator.currentEpisodes.isEmpty ? episodes : coordinator.currentEpisodes
        return EpisodeDrawerSheet(
            episodes: activeEpisodes,
            currentEpisodeNumber: coordinator.currentEpisode?.episodeNumber ?? 1,
            onSelectEpisode: { ep in
                showingEpisodeDrawer = false
                let targetIdx = activeEpisodes.firstIndex(where: { $0.id == ep.id }) ?? max(0, ep.episodeNumber - 1)
                coordinator.loadEpisodes(activeEpisodes, dramaTitle: coordinator.currentDramaTitle, startingAt: targetIdx)
                scheduleAutoHide()
            }
        )
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}
