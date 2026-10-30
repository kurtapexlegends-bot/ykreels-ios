import SwiftUI
import AVKit
import ReelCore
import ReelDatabase
import ReelEngine
import ReelPlayer

/// Ultra-minimalist vertical 9:16 short-drama reel player feed.
/// Features Apple glassmorphism, Soft Pastel Sakura Pink accents,
/// compact right-edge action stack, and edge-to-edge full-bleed playback.
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

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ReelTheme.pureBlack

                // MARK: - Video Layer (Edge-to-Edge Full Screen)
                if let player = coordinator.activePlayer {
                    ReelPlayerRepresentable(player: player) {
                        coordinator.markFirstFrameRendered()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                }

                // MARK: - Immediate Visual Artwork & Buffering Indicator (Zero Black Freeze)
                if coordinator.isBuffering || !coordinator.hasRenderedFirstFrame {
                    bufferingPosterLayer(size: geometry.size)
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
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .onTapGesture {
                handleSingleTap()
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
        .onAppear {
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

    // MARK: - Buffering Poster Layer (Eliminates Black Freeze)
    private func bufferingPosterLayer(size: CGSize) -> some View {
        ZStack {
            let coverURL = coordinator.currentEpisode?.thumbnailURL ?? coordinator.currentDramaCoverURL ?? WrongMatchRightCrushData.drama.coverURL
            if let cover = coverURL {
                AsyncImage(url: cover) { phase in
                    if let img = phase.image {
                        img.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                            .blur(radius: 8)
                    } else {
                        posterFallbackGradient
                    }
                }
            } else {
                posterFallbackGradient
            }

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

    private var posterFallbackGradient: some View {
        LinearGradient(
            colors: [Color(white: 0.16), Color(white: 0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Gestures & Interactions
    private func handleSingleTap() {
        coordinator.togglePlayPause()
        withAnimation(.easeOut(duration: 0.2)) {
            showPlayPausePulse = true
            isHUDVisible = true
        }
        scheduleAutoHide()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            withAnimation(.easeIn(duration: 0.25)) {
                showPlayPausePulse = false
            }
        }
    }

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
            onSelectEpisode: { ep in
                showingEpisodeDrawer = false
                let targetIdx = coordinator.currentEpisodes.firstIndex(where: { $0.id == ep.id }) ?? max(0, ep.episodeNumber - 1)
                coordinator.loadEpisodes(
                    coordinator.currentEpisodes,
                    dramaTitle: coordinator.currentDramaTitle,
                    coverURL: coordinator.currentDramaCoverURL,
                    startingAt: targetIdx
                )
                scheduleAutoHide()
            }
        )
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}
