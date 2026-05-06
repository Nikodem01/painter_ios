import HotwireNative
import UIKit
import UserNotifications

final class PushRegistrationComponent: BridgeComponent {
    override class var name: String { "push-registration" }

    private struct TokenPayload: Encodable {
        let token: String
        let platform: String
    }

    override func onReceive(message: Message) {
        guard message.event == "request-token" else { return }
        Task { await requestAndReply() }
    }

    private func requestAndReply() async {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        guard granted else { return }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            AppDelegate.requestAPNSToken { [weak self] token in
                let payload = TokenPayload(token: token, platform: "apns")
                self?.reply(to: "request-token", with: payload)
                continuation.resume()
            }
        }
    }
}
