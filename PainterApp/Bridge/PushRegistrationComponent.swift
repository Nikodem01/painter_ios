import HotwireNative
import UIKit
import UserNotifications

final class PushRegistrationComponent: BridgeComponent {
    override class var name: String { "push-registration" }

    override func onReceive(message: Message) {
        guard message.event == "request-token" else { return }
        requestAPNSToken()
    }

    // MARK: - Private

    private func requestAPNSToken() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                self?.listenForToken()
            }
        }
    }

    private func listenForToken() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tokenReceived(_:)),
            name: .apnsTokenReceived,
            object: nil
        )
    }

    @objc private func tokenReceived(_ notification: Foundation.Notification) {
        guard let token = notification.object as? String else { return }
        NotificationCenter.default.removeObserver(self, name: .apnsTokenReceived, object: nil)

        let data = MessageData(metadata: [:], data: ["token": token, "platform": "ios"])
        reply(with: message(replacing: data))
    }
}
