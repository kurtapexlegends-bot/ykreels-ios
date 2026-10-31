import SwiftUI
import ReelCore

#if canImport(UIKit)
import UIKit
#endif

/// High-performance drama poster image loader.
/// Prioritizes zero-latency pre-bundled asset catalog images before falling back
/// to remote CDN loading and an Apple-styled glassmorphic placeholder.
public struct DramaCoverImage: View {
    public let drama: Drama
    public var cornerRadius: CGFloat = ReelTheme.cornerRadiusMedium

    public init(drama: Drama, cornerRadius: CGFloat = ReelTheme.cornerRadiusMedium) {
        self.drama = drama
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        if let uiImage = UIImage(named: drama.id) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            remoteAsyncImage
        }
        #else
        remoteAsyncImage
        #endif
    }

    private var remoteAsyncImage: some View {
        AsyncImage(url: drama.coverURL) { phase in
            if let img = phase.image {
                img.resizable().aspectRatio(contentMode: .fill)
            } else {
                fallbackPlaceholder
            }
        }
    }

    private var fallbackPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(white: 0.20), Color(white: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: "film.fill")
                    .font(.system(size: 28))
                    .foregroundColor(ReelTheme.sakuraPink.opacity(0.85))

                Text(drama.title)
                    .font(.caption2.bold())
                    .foregroundColor(ReelTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                    .lineLimit(2)
            }
        }
    }
}
