import SwiftUI
import AVFoundation

#if os(iOS)
import UIKit

/// High-performance full-bleed hardware-accelerated AVPlayerLayer view.
/// Replaces standard SwiftUI VideoPlayer to eliminate default safe-area letterboxing,
/// controls container margin deductions, and black border clamping.
public struct ReelPlayerRepresentable: UIViewRepresentable {
    public let player: AVPlayer

    public init(player: AVPlayer) {
        self.player = player
    }

    public func makeUIView(context: Context) -> ReelPlayerLayerView {
        let view = ReelPlayerLayerView()
        view.backgroundColor = .black
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    public func updateUIView(_ uiView: ReelPlayerLayerView, context: Context) {
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
        }
        uiView.playerLayer.videoGravity = .resizeAspectFill
    }
}

public final class ReelPlayerLayerView: UIView {
    public override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    public var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
#elseif os(macOS)
import AppKit

public struct ReelPlayerRepresentable: NSViewRepresentable {
    public let player: AVPlayer

    public init(player: AVPlayer) {
        self.player = player
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = playerLayer
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        if let playerLayer = nsView.layer as? AVPlayerLayer, playerLayer.player !== player {
            playerLayer.player = player
        }
    }
}
#endif

