import SwiftUI

/// Design system tokens for YKReels.
/// Strictly enforces True Black OLED `#000000`, Apple glassmorphism,
/// and Soft Pastel Sakura Pink `#FF8DA1` accents with zero UI slop.
public enum ReelTheme {
    // MARK: - OLED & Surface Colors
    public static let pureBlack = Color(red: 0, green: 0, blue: 0)
    public static let surfaceDark = Color(red: 0.08, green: 0.08, blue: 0.10)
    public static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.14)

    // MARK: - Soft Pastel Sakura Pink Accent
    /// Primary accent: Soft Pastel Sakura Pink (#FF8DA1).
    public static let sakuraPink = Color(red: 1.0, green: 0.553, blue: 0.631)
    /// Secondary highlight: Light Sakura Mist (#FFB3C1).
    public static let sakuraMist = Color(red: 1.0, green: 0.702, blue: 0.757)
    /// Subtle atmospheric pink glow for glass pills and active highlights.
    public static let sakuraGlow = Color(red: 1.0, green: 0.553, blue: 0.631).opacity(0.15)

    // Alias for core accent
    public static let accent = sakuraPink

    // MARK: - Glassmorphism Specular Borders
    public static let glassBorder = Color.white.opacity(0.14)
    public static let glassBorderHighlight = sakuraPink.opacity(0.35)

    // MARK: - Text Hierarchy
    public static let textPrimary = Color.white
    public static let textSecondary = Color.white.opacity(0.72)
    public static let textTertiary = Color.white.opacity(0.45)

    // MARK: - Corner Radii
    public static let cornerRadiusSmall: CGFloat = 8.0
    public static let cornerRadiusMedium: CGFloat = 14.0
    public static let cornerRadiusLarge: CGFloat = 20.0
    public static let cornerRadiusPill: CGFloat = 100.0

    // MARK: - Layout Constants
    public static let verticalReelAspectRatio: CGFloat = 9.0 / 16.0
    public static let bottomOverlayGradientHeight: CGFloat = 180.0
    public static let topOverlayGradientHeight: CGFloat = 110.0

    // MARK: - Butter-Smooth Motion Springs
    /// Standardized spring curve tuned for 120Hz ProMotion displays.
    public static let butterSpring = Animation.spring(response: 0.32, dampingFraction: 0.82)
    public static let fastSpring = Animation.spring(response: 0.24, dampingFraction: 0.88)
}
