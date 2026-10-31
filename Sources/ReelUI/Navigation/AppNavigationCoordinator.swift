import SwiftUI

/// Shared singleton navigation coordinator for cross-tab switching and deep linking.
@MainActor
public final class AppNavigationCoordinator: ObservableObject {
    public static let shared = AppNavigationCoordinator()

    @Published public var selectedTab: Int = 0
    @Published public var isPlayerHUDVisible: Bool = true

    public init() {}

    public func switchToFeed() {
        selectedTab = 0
    }
}
