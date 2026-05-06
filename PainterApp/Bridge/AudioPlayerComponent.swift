import AVFoundation
import HotwireNative
import MediaPlayer

final class AudioPlayerComponent: BridgeComponent {
    override class var name: String { "audio-player" }

    private struct ReadyPayload: Decodable {
        let url: String
        let title: String?
        let artist: String?
        let duration: Double?
    }

    private struct SeekPayload: Decodable {
        let time: Double
    }

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    override func onReceive(message: Message) {
        switch message.event {
        case "ready":
            guard let payload: ReadyPayload = message.data(),
                  let url = URL(string: payload.url) else { return }
            prepare(url: url, metadata: payload)
        case "play":
            player?.play()
        case "pause":
            player?.pause()
        case "seek":
            guard let payload: SeekPayload = message.data() else { return }
            player?.seek(to: CMTime(seconds: payload.time, preferredTimescale: 600))
        default:
            break
        }
    }

    private func prepare(url: URL, metadata: ReadyPayload) {
        configureAudioSession()
        teardown()

        let player = AVPlayer(url: url)
        self.player = player

        configureNowPlayingInfo(metadata: metadata)
        configureRemoteCommands()
        observeEnd(item: player.currentItem)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }

    private func teardown() {
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
        player?.pause()
        player = nil
    }

    private func configureNowPlayingInfo(metadata: ReadyPayload) {
        var info: [String: Any] = [:]
        if let title = metadata.title { info[MPMediaItemPropertyTitle] = title }
        if let artist = metadata.artist { info[MPMediaItemPropertyArtist] = artist }
        if let duration = metadata.duration { info[MPMediaItemPropertyPlaybackDuration] = duration }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.removeTarget(nil)
        center.pauseCommand.removeTarget(nil)
        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.player?.play() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.player?.pause() }
            return .success
        }
    }

    private func observeEnd(item: AVPlayerItem?) {
        guard let item else { return }
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in }
    }
}
