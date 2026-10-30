import SwiftUI
import AVFoundation

#if os(iOS)
import UIKit

/// High-performance full-bleed hardware-accelerated AVPlayerLayer view.
/// Replaces standard SwiftUI VideoPlayer to eliminate default safe-area letterboxing,
/// controls container margin deductions, and black border clamping.
public struct ReelPlayerRepresentable: UIViewRepresentable {
    public let player: AVPlayer
    public var onFirstFrameRendered: (() -> Void)?

    public init(player: AVPlayer, onFirstFrameRendered: (() -> Void)? = nil) {
        self.player = player
        self.onFirstFrameRendered = onFirstFrameRendered
    }

    public func makeUIView(context: Context) -> ReelPlayerLayerView {
        let view = ReelPlayerLayerView()
        view.backgroundColor = .black
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.onFirstFrameRendered = onFirstFrameRendered
        view.startObserving()
        return view
    }

    public func updateUIView(_ uiView: ReelPlayerLayerView, context: Context) {
        uiView.onFirstFrameRendered = onFirstFrameRendered
        if uiView.playerLayer.player !== player {
            uiView.playerLayer.player = player
            uiView.startObserving()
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

    public var onFirstFrameRendered: (() -> Void)?
    private var displayObservation: NSKeyValueObservation?

    public func startObserving() {
        displayObservation?.invalidate()
        if playerLayer.isReadyForDisplay {
            onFirstFrameRendered?()
        } else {
            displayObservation = playerLayer.observe(\.isReadyForDisplay, options: [.new]) { [weak self] l, _ in
                if l.isReadyForDisplay {
                    DispatchQueue.main.async { self?.onFirstFrameRendered?() }
                }
            }
        }
    }

    deinit {
        displayObservation?.invalidate()
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
    public var onFirstFrameRendered: (() -> Void)?

    public init(player: AVPlayer, onFirstFrameRendered: (() -> Void)? = nil) {
        self.player = player
        self.onFirstFrameRendered = onFirstFrameRendered
    }

    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = playerLayer
        if playerLayer.isReadyForDisplay {
            onFirstFrameRendered?()
        }
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        if let playerLayer = nsView.layer as? AVPlayerLayer, playerLayer.player !== player {
            playerLayer.player = player
        }
    }
}
#endif
