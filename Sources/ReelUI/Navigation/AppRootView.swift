import SwiftUI
import ReelCore
import ReelEngine
import ReelPlayer

/// Root navigation shell containing the 3-tab experience:
/// Tab 1: Feed (Instant vertical short-drama reel player)
/// Tab 2: Explore (Catalog, genres, search)
/// Tab 3: Library (Continue watching, 250MB cache manager)
@MainActor
public struct AppRootView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Feed
            PlayerFeedView()
                .tabItem {
                    Label("Reels", systemImage: "play.rectangle.on.rectangle.fill")
                }
                .tag(0)

            // Tab 2: Explore
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)

            // Tab 3: Library
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(2)
        }
        .tint(ReelTheme.sakuraPink)
        .background(ReelTheme.pureBlack)
        .preferredColorScheme(.dark)
    }
}
