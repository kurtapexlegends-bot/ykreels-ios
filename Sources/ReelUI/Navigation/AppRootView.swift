import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer

/// Root navigation shell containing the 3-tab experience:
/// Tab 0: Feed (Instant vertical short-drama reel player)
/// Tab 1: Explore (Catalog, genres, search)
/// Tab 2: Library (Continue watching, 250MB cache manager)
///
/// Employs a deterministic switching container and an Apple glassmorphic
/// floating tab bar to completely eliminate tab ghosting / view overlay bugs
/// and deliver edge-to-edge full-bleed playback.
@MainActor
public struct AppRootView: View {
    @ObservedObject private var navigation = AppNavigationCoordinator.shared

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            ReelTheme.pureBlack
                .ignoresSafeArea()

            // Deterministic Tab Container - prevents tab ghosting / layer overlapping
            Group {
                switch navigation.selectedTab {
                case 0:
                    PlayerFeedView()
                case 1:
                    ExploreView()
                case 2:
                    LibraryView()
                default:
                    PlayerFeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Apple Glassmorphic Floating Tab Bar
            floatingTabBar
        }
        .ignoresSafeArea()
        .tint(ReelTheme.sakuraPink)
        .preferredColorScheme(.dark)
    }

    // MARK: - Floating Glass Tab Bar
    private var floatingTabBar: some View {
        HStack(spacing: 8) {
            tabBarItem(
                index: 0,
                title: "Reels",
                systemImage: "play.rectangle.on.rectangle.fill"
            )
            tabBarItem(
                index: 1,
                title: "Explore",
                systemImage: "magnifyingglass"
            )
            tabBarItem(
                index: 2,
                title: "Library",
                systemImage: "books.vertical.fill"
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(ReelTheme.glassBorder, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.45), radius: 12, y: 6)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private func tabBarItem(index: Int, title: String, systemImage: String) -> some View {
        let isSelected = navigation.selectedTab == index
        return Button(action: {
            withAnimation(ReelTheme.butterSpring) {
                navigation.selectedTab = index
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))

                if isSelected {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? ReelTheme.sakuraPink : ReelTheme.textTertiary)
            .padding(.horizontal, isSelected ? 14 : 10)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? ReelTheme.sakuraPink.opacity(0.18) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
