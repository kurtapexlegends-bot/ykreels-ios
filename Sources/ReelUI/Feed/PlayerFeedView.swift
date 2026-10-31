import SwiftUI
import AVKit
import ReelCore
import ReelDatabase
import ReelEngine
import ReelPlayer

/// Ultra-minimalist vertical 9:16 short-drama reel player feed.
/// Features Apple glassmorphism, Soft Pastel Sakura Pink accents,
/// interactive vertical swipe paging, auto-hiding immersive HUD,
/// and edge-to-edge full-bleed playback.
@MainActor
public struct PlayerFeedView: View {
    @StateObject private var coordinator = PlayerPoolCoordinator.shared
    @State private var showingEpisodeDrawer: Bool = false
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var showHeartAnimation: Bool = false
    @State private var showPlayPausePulse: Bool = false
    @State private var isHUDVisible: Bool = true
    @State private var autoHideTask: Task<Void, Never>?
    @State private var dragOffsetY: CGFloat = 0.0

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                ReelTheme.pureBlack
                    .ignoresSafeArea()

                // MARK: - Previous Episode Peek (During Downward Drag)
                if dragOffsetY > 0, let prevEp = coordinator.previousEpisode {
                    adjacentEpisodeCard(episode: prevEp, size: size)
                        .offset(y: -size.height + dragOffsetY)
                }

                // MARK: - Active Video Layer (Edge-to-Edge Full Screen)
                ZStack {
                    if let player = coordinator.activePlayer {
                        ReelPlayerRepresentable(player: player) {
                            coordinator.markFirstFrameRendered()
                        }
                        .frame(width: size.width, height: size.height)
                        .clipped()
                    }

                    // 0ms Keyframe Cover & Buffering Indicator (Zero Black Freeze)
                    if coordinator.isBuffering || !coordinator.hasRenderedFirstFrame {
                        bufferingPosterLayer(size: size)
                    }
                }
                .frame(width: size.width, height: size.height)
                .offset(y: dragOffsetY)

                // MARK: - Next Episode Peek (During Upward Drag)
                if dragOffsetY < 0, let nextEp = coordinator.nextEpisode {
                    adjacentEpisodeCard(episode: nextEp, size: size)
                        .offset(y: size.height + dragOffsetY)
                }

                // MARK: - Glassmorphic HUD Overlays
                if isHUDVisible {
                    ReelHUDOverlayView(
                        coordinator: coordinator,
                        isLiked: $isLiked,
                        isBookmarked: $isBookmarked,
                        onShowEpisodes: { showingEpisodeDrawer = true },
                        onUserInteraction: { scheduleAutoHide() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }

                // MARK: - Center Play/Pause Pulse Indicator
                if showPlayPausePulse {
                    Image(systemName: coordinator.isPlaying ? "play.fill" : "pause.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 76, height: 76)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.8))
                        .shadow(color: Color.black.opacity(0.5), radius: 12)
                        .transition(.scale.combined(with: .opacity))
                }

                // MARK: - Double-Tap Heart Burst Animation
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 72))
                        .foregroundColor(ReelTheme.sakuraPink)
                        .shadow(color: ReelTheme.sakuraPink.opacity(0.8), radius: 18)
                        .scaleEffect(showHeartAnimation ? 1.15 : 0.6)
                        .opacity(showHeartAnimation ? 1.0 : 0.0)
                        .animation(ReelTheme.butterSpring, value: showHeartAnimation)
                }
            }
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                triggerDoubleTapLike()
            }
            .onTapGesture(count: 1) {
                handleSingleTap()
            }
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onChanged { value in
                        handleDragChanged(value)
                    }
                    .onEnded { value in
                        handleDragEnded(value, screenHeight: size.height)
                    }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            isHUDVisible = true
            AppNavigationCoordinator.shared.isPlayerHUDVisible = true
            if coordinator.currentEpisodes.isEmpty {
                loadInitialEpisodes()
            } else {
                coordinator.resume()
                scheduleAutoHide()
            }
        }
        .onDisappear {
            coordinator.pause()
            autoHideTask?.cancel()
        }
        .sheet(isPresented: $showingEpisodeDrawer) { episodeDrawerSheet }
    }

    // MARK: - Adjacent Episode Peek Card
    private func adjacentEpisodeCard(episode: Episode, size: CGSize) -> some View {
        ZStack(alignment: .bottomLeading) {
            ReelTheme.pureBlack
            episodePoster(dramaId: episode.dramaId, coverURL: episode.thumbnailURL ?? coordinator.currentDramaCoverURL, size: size)

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Ep \(episode.episodeNumber)")
                    .font(.caption.bold())
                    .foregroundColor(ReelTheme.sakuraPink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())

                Text(episode.title)
                    .font(.subheadline.bold())
                    .foregroundColor(ReelTheme.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    // MARK: - Buffering Poster Layer (Eliminates Black Freeze)
    private func bufferingPosterLayer(size: CGSize) -> some View {
        ZStack {
            let dramaId = coordinator.currentEpisode?.dramaId ?? WrongMatchRightCrushData.drama.id
            let coverURL = coordinator.currentEpisode?.thumbnailURL ?? coordinator.currentDramaCoverURL ?? WrongMatchRightCrushData.drama.coverURL
            episodePoster(dramaId: dramaId, coverURL: coverURL, size: size)

            VStack(spacing: 10) {
                ProgressView()
                    .tint(ReelTheme.sakuraPink)
                    .scaleEffect(1.2)

                Text("Buffering reel...")
                    .font(.caption2.bold())
                    .foregroundColor(ReelTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }
        }
        .frame(width: size.width, height: size.height)
        .transition(.opacity)
    }

    private func episodePoster(dramaId: String, coverURL: URL?, size: CGSize) -> some View {
        Group {
            #if os(iOS)
            if let uiImage = UIImage(named: dramaId) {
                Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
            } else if let cover = coverURL {
                AsyncImage(url: cover) { phase in
                    if let img = phase.image { img.resizable().aspectRatio(contentMode: .fill) } else { posterFallbackGradient }
                }
            } else {
                posterFallbackGradient
            }
            #else
            posterFallbackGradient
            #endif
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    private var posterFallbackGradient: some View {
        LinearGradient(
            colors: [Color(white: 0.16), Color(white: 0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Gestures & Interactions
    private func handleSingleTap() {
        if !isHUDVisible {
            withAnimation(ReelTheme.butterSpring) {
                isHUDVisible = true
                AppNavigationCoordinator.shared.isPlayerHUDVisible = true
            }
            scheduleAutoHide()
        } else {
            coordinator.togglePlayPause()
            withAnimation(.easeOut(duration: 0.2)) {
                showPlayPausePulse = true
            }
            if coordinator.isPlaying {
                scheduleAutoHide()
            } else {
                autoHideTask?.cancel()
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000)
                withAnimation(.easeIn(duration: 0.25)) {
                    showPlayPausePulse = false
                }
            }
        }
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        let vertical = value.translation.height
        let horizontal = value.translation.width
        guard abs(vertical) > abs(horizontal) else { return }

        let hasPrev = coordinator.hasPreviousEpisode
        let hasNext = coordinator.hasNextEpisode

        if (vertical > 0 && !hasPrev) || (vertical < 0 && !hasNext) {
            dragOffsetY = vertical * 0.25
        } else {
            dragOffsetY = vertical
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value, screenHeight: CGFloat) {
        let vertical = value.translation.height
        let velocity = value.predictedEndTranslation.height - vertical
        let threshold: CGFloat = 65
        let hasPrev = coordinator.hasPreviousEpisode
        let hasNext = coordinator.hasNextEpisode

        if (vertical < -threshold || velocity < -180) && hasNext {
            withAnimation(ReelTheme.butterSpring) {
                dragOffsetY = -screenHeight
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                coordinator.advanceToNextEpisode()
                dragOffsetY = 0
                scheduleAutoHide()
            }
        } else if (vertical > threshold || velocity > 180) && hasPrev {
            withAnimation(ReelTheme.butterSpring) {
                dragOffsetY = screenHeight
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                coordinator.returnToPreviousEpisode()
                dragOffsetY = 0
                scheduleAutoHide()
            }
        } else {
            withAnimation(ReelTheme.butterSpring) {
                dragOffsetY = 0
            }
        }
    }

    private func scheduleAutoHide() {
        autoHideTask?.cancel()
        guard coordinator.isPlaying else { return }
        autoHideTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled, coordinator.isPlaying else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                isHUDVisible = false
                AppNavigationCoordinator.shared.isPlayerHUDVisible = false
            }
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
            coordinator.loadEpisodes(eps, dramaTitle: initialDrama.title, coverURL: initialDrama.coverURL, startingAt: 0)
            scheduleAutoHide()
            Task(priority: .utility) { await CuratedDramaCatalog.shared.syncFromRemote() }
        }
    }

    // MARK: - Episode Drawer Sheet
    private var episodeDrawerSheet: some View {
        EpisodeDrawerSheet(
            episodes: coordinator.currentEpisodes,
            currentEpisodeNumber: coordinator.currentEpisode?.episodeNumber ?? 1,
            dramaTitle: coordinator.currentDramaTitle,
            onSelectEpisode: { ep in
                showingEpisodeDrawer = false
                let targetIdx = coordinator.currentEpisodes.firstIndex(where: { $0.id == ep.id }) ?? max(0, ep.episodeNumber - 1)
                coordinator.loadEpisodes(
                    coordinator.currentEpisodes,
                    dramaTitle: coordinator.currentDramaTitle,
                    coverURL: coordinator.currentDramaCoverURL,
                    startingAt: targetIdx
                )
                withAnimation(ReelTheme.butterSpring) {
                    isHUDVisible = true
                    AppNavigationCoordinator.shared.isPlayerHUDVisible = true
                }
                scheduleAutoHide()
            }
        )
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}
