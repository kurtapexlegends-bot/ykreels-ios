import SwiftUI
import ReelCore
import ReelPlayer

/// Modular Glassmorphic HUD Overlay for the Reel Player.
/// Houses the non-truncating top title header, lower-right compact action stack
/// (Play/Pause, Like, Save, Episodes), timecode metrics, and interactive scrub bar.
@MainActor
public struct ReelHUDOverlayView: View {
    @ObservedObject var coordinator: PlayerPoolCoordinator
    @Binding var isLiked: Bool
    @Binding var isBookmarked: Bool
    let onShowEpisodes: () -> Void
    let onUserInteraction: () -> Void

    @State private var isScrubbing: Bool = false
    @State private var scrubRatio: Double = 0.0

    public init(
        coordinator: PlayerPoolCoordinator,
        isLiked: Binding<Bool>,
        isBookmarked: Binding<Bool>,
        onShowEpisodes: @escaping () -> Void,
        onUserInteraction: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self._isLiked = isLiked
        self._isBookmarked = isBookmarked
        self.onShowEpisodes = onShowEpisodes
        self.onUserInteraction = onUserInteraction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topGlassBar
            Spacer()
            bottomGlassHUD
        }
    }

    // MARK: - Top Glass Bar (No Title Truncation)
    private var topGlassBar: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(coordinator.currentDramaTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ReelTheme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .shadow(color: Color.black.opacity(0.85), radius: 4, y: 1)

                if let current = coordinator.currentEpisode {
                    Text("Ep \(current.episodeNumber) / \(max(1, coordinator.currentEpisodes.count))")
                        .font(.caption2.bold())
                        .foregroundColor(ReelTheme.sakuraPink)
                }
            }

            Spacer(minLength: 8)

            Button(action: cyclePlaybackSpeed) {
                Text(String(format: "%.2fx", coordinator.playbackRate))
                    .font(.caption2.bold())
                    .foregroundColor(ReelTheme.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 54)
    }

    // MARK: - Bottom Glass HUD
    private var bottomGlassHUD: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 14) {
                // Left: Episode Title & Timecode
                VStack(alignment: .leading, spacing: 4) {
                    if let current = coordinator.currentEpisode {
                        Text(current.title)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(ReelTheme.textPrimary)
                            .lineLimit(2)
                            .shadow(color: Color.black.opacity(0.8), radius: 4, y: 1)

                        HStack(spacing: 6) {
                            Text(formattedTimeProgress)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(ReelTheme.textSecondary)

                            Text("•")
                                .font(.caption2)
                                .foregroundColor(ReelTheme.textTertiary)

                            Text("Vertical 9:16")
                                .font(.caption2)
                                .foregroundColor(ReelTheme.sakuraMist)
                        }
                    }
                }

                Spacer(minLength: 10)

                // Right: Compact Vertical Actions (Clean, 38x38 glass buttons)
                VStack(spacing: 8) {
                    compactActionButton(
                        systemImage: coordinator.isPlaying ? "pause.fill" : "play.fill",
                        label: coordinator.isPlaying ? "Pause" : "Play",
                        tint: .white,
                        action: { coordinator.togglePlayPause() }
                    )

                    compactActionButton(
                        systemImage: isLiked ? "heart.fill" : "heart",
                        label: isLiked ? "Liked" : "Like",
                        tint: isLiked ? ReelTheme.sakuraPink : .white,
                        action: { isLiked.toggle() }
                    )

                    compactActionButton(
                        systemImage: isBookmarked ? "bookmark.fill" : "bookmark",
                        label: isBookmarked ? "Saved" : "Save",
                        tint: isBookmarked ? ReelTheme.sakuraPink : .white,
                        action: { isBookmarked.toggle() }
                    )

                    compactActionButton(
                        systemImage: "rectangle.stack.fill",
                        label: "Episodes",
                        tint: .white,
                        action: onShowEpisodes
                    )
                }
            }
            .padding(.horizontal, 16)

            scrubBar
        }
        .padding(.bottom, 82)
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
                    .frame(height: 3)

                Capsule()
                    .fill(ReelTheme.sakuraPink)
                    .frame(width: max(4, scrubGeo.size.width * displayRatio), height: 3)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard coordinator.totalDuration > 0, coordinator.totalDuration.isFinite else { return }
                        isScrubbing = true
                        scrubRatio = max(0, min(Double(value.location.x / scrubGeo.size.width), 1.0))
                        onUserInteraction()
                    }
                    .onEnded { value in
                        guard coordinator.totalDuration > 0, coordinator.totalDuration.isFinite else {
                            isScrubbing = false
                            return
                        }
                        let finalRatio = max(0, min(Double(value.location.x / scrubGeo.size.width), 1.0))
                        coordinator.seek(to: finalRatio * coordinator.totalDuration)
                        isScrubbing = false
                        onUserInteraction()
                    }
            )
        }
        .frame(height: 14)
        .padding(.horizontal, 16)
    }

    // MARK: - Compact Action Button
    private func compactActionButton(systemImage: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            onUserInteraction()
            action()
        }) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5))
                    .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)

                Text(label)
                    .font(.system(size: 9, weight: .medium))
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

    private func cyclePlaybackSpeed() {
        onUserInteraction()
        let rates: [Float] = [1.0, 1.25, 1.5, 2.0]
        let nextIndex = ((rates.firstIndex(of: coordinator.playbackRate) ?? 0) + 1) % rates.count
        coordinator.setPlaybackRate(rates[nextIndex])
    }
}
