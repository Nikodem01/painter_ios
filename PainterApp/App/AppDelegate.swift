import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private let navigator = MainNavigator()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window {
            navigator.start(in: window)
        }
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NotificationCenter.default.post(name: .apnsTokenReceived, object: token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[APNS] Failed to register: \(error)")
    }
}

extension Notification.Name {
    static let apnsTokenReceived = Notification.Name("apnsTokenReceived")
}
