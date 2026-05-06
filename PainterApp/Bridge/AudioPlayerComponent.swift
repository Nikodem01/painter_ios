import AVFoundation
import HotwireNative

final class AudioPlayerComponent: BridgeComponent {
    override class var name: String { "audio-player" }

    private var player: AVPlayer?

    override func onReceive(message: Message) {
        switch message.event {
        case "play":
            guard let urlString = message.data["url"] as? String,
                  let url = URL(string: urlString) else { return }
            play(url: url)
        case "pause":
            player?.pause()
            notifyState("paused")
        default:
            break
        }
    }

    // MARK: - Private

    private func play(url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
            observePlayerStatus()
        }
        player?.play()
        notifyState("playing")
    }

    private func observePlayerStatus() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }

    @objc private func playerDidFinish() {
        notifyState("ended")
    }

    private func notifyState(_ state: String) {
        let data = MessageData(metadata: [:], data: ["state": state])
        reply(with: message(replacing: data))
    }
}
