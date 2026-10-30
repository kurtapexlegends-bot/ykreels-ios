import Foundation
import AVFoundation
import ReelCore

/// High-performance AVPlayer pool coordinator.
/// Enforces a strict 3-player sliding window (Previous, Current, Next) to prevent
/// memory bloat, audio collisions, and decoding pipeline starvation (<80MB RAM).
@MainActor
public final class PlayerPoolCoordinator: ObservableObject {
    public static let shared = PlayerPoolCoordinator()

    @Published public private(set) var currentEpisode: Episode?
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var currentPlayhead: Double = 0.0
    @Published public private(set) var totalDuration: Double = 0.0
    @Published public private(set) var playbackRate: Float = 1.0
    public var onProgressUpdate: ((Episode, Double, Double) -> Void)?

    private var currentPlayer: AVPlayer?
    private var nextPlayer: AVPlayer?
    private var previousPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private var itemEndObserver: Any?
    private var episodes: [Episode] = []
    private var currentIndex: Int = 0
    private var lastProgressReport: Date = .distantPast

    public init() {
        #if os(iOS)
        let audio = AVAudioSession.sharedInstance()
        try? audio.setCategory(.playback, mode: .moviePlayback)
        try? audio.setActive(true)
        #endif
    }

    public func loadEpisodes(_ episodeList: [Episode], startingAt index: Int = 0, initialSeek: Double = 0.0) {
        guard !episodeList.isEmpty else { return }
        self.episodes = episodeList
        self.currentIndex = max(0, min(index, episodeList.count - 1))
        rebuildPlayerPool()
        if initialSeek > 0 { seek(to: initialSeek) }
    }

    private func rebuildPlayerPool() {
        cleanupAllPlayers()
        guard currentIndex < episodes.count else { return }
        self.currentEpisode = episodes[currentIndex]
        self.currentPlayhead = 0.0
        self.totalDuration = currentEpisode?.durationSeconds ?? 0.0
        if let currentURL = currentEpisode?.primaryStreamURL {
            let player = makeConfiguredPlayer(url: currentURL)
            self.currentPlayer = player
            attachObservers(to: player)
            player.play()
            if playbackRate != 1.0 { player.rate = playbackRate }
            self.isPlaying = true
        }
        prepareAdjacentPlayers()
    }

    private func makeConfiguredPlayer(url: URL) -> AVPlayer {
        let player = AVPlayer(playerItem: AVPlayerItem(url: url))
        player.actionAtItemEnd = .none
        return player
    }

    private func prepareAdjacentPlayers() {
        let nextIdx = currentIndex + 1
        if nextIdx < episodes.count, let url = episodes[nextIdx].primaryStreamURL {
            self.nextPlayer = makeConfiguredPlayer(url: url)
        }
        let prevIdx = currentIndex - 1
        if prevIdx >= 0, let url = episodes[prevIdx].primaryStreamURL {
            self.previousPlayer = makeConfiguredPlayer(url: url)
        }
    }

    public func advanceToNextEpisode() {
        guard currentIndex + 1 < episodes.count else { isPlaying = false; return }
        reportProgress()
        releasePlayer(&previousPlayer)
        detachObservers()
        currentPlayer?.pause()
        previousPlayer = currentPlayer
        currentIndex += 1
        currentPlayer = nextPlayer
        nextPlayer = nil
        currentEpisode = episodes[currentIndex]
        activateCurrentPlayer()

        let nextIdx = currentIndex + 1
        if nextIdx < episodes.count, let url = episodes[nextIdx].primaryStreamURL {
            self.nextPlayer = makeConfiguredPlayer(url: url)
        }
    }

    public func returnToPreviousEpisode() {
        guard currentIndex > 0 else { return }
        reportProgress()
        releasePlayer(&nextPlayer)
        detachObservers()
        currentPlayer?.pause()
        nextPlayer = currentPlayer
        currentIndex -= 1
        currentPlayer = previousPlayer
        previousPlayer = nil
        currentEpisode = episodes[currentIndex]
        activateCurrentPlayer()

        let prevIdx = currentIndex - 1
        if prevIdx >= 0, let url = episodes[prevIdx].primaryStreamURL {
            self.previousPlayer = makeConfiguredPlayer(url: url)
        }
    }

    private func activateCurrentPlayer() {
        currentPlayhead = 0.0
        totalDuration = currentEpisode?.durationSeconds ?? 0.0
        let player = currentPlayer ?? currentEpisode?.primaryStreamURL.map { makeConfiguredPlayer(url: $0) }
        guard let active = player else { return }
        currentPlayer = active
        attachObservers(to: active)
        active.play()
        if playbackRate != 1.0 { active.rate = playbackRate }
        isPlaying = true
    }

    public func togglePlayPause() {
        guard let player = currentPlayer else { return }
        isPlaying ? player.pause() : player.play()
        isPlaying.toggle()
        if isPlaying && playbackRate != 1.0 { player.rate = playbackRate }
        reportProgress()
    }

    public func seek(to seconds: Double) {
        guard let player = currentPlayer else { return }
        currentPlayhead = seconds
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        reportProgress()
    }

    public func setPlaybackRate(_ rate: Float) {
        self.playbackRate = rate
        if isPlaying { currentPlayer?.rate = rate }
    }

    private func reportProgress() {
        guard let ep = currentEpisode else { return }
        lastProgressReport = Date()
        onProgressUpdate?(ep, currentPlayhead, totalDuration)
    }

    private func attachObservers(to player: AVPlayer) {
        detachObservers()
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentPlayhead = time.seconds
            if let dur = player.currentItem?.duration.seconds, dur.isFinite, !dur.isNaN, dur > 0 {
                self.totalDuration = dur
            }
            if Date().timeIntervalSince(self.lastProgressReport) >= 3.0 {
                self.reportProgress()
            }
        }
        if let item = player.currentItem {
            itemEndObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
            ) { [weak self] _ in
                Task { @MainActor [weak self] in self?.advanceToNextEpisode() }
            }
        }
    }

    private func detachObservers() {
        if let token = timeObserverToken { currentPlayer?.removeTimeObserver(token); timeObserverToken = nil }
        if let endObs = itemEndObserver { NotificationCenter.default.removeObserver(endObs); itemEndObserver = nil }
    }

    private func releasePlayer(_ player: inout AVPlayer?) {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    public func cleanupAllPlayers() {
        detachObservers()
        releasePlayer(&currentPlayer)
        releasePlayer(&nextPlayer)
        releasePlayer(&previousPlayer)
    }

    public var activePlayer: AVPlayer? { currentPlayer }
}
