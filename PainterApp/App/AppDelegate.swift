import UIKit

@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private var navigator: MainNavigator?

    static var apnsToken: String?
    static var apnsTokenHandlers: [(String) -> Void] = []

    static func requestAPNSToken(handler: @escaping @MainActor (String) -> Void) {
        if let token = apnsToken {
            handler(token)
        } else {
            apnsTokenHandlers.append(handler)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let navigator = MainNavigator()
        self.navigator = navigator

        let window = UIWindow(frame: UIScreen.main.bounds)
        navigator.start(in: window)
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Self.apnsToken = token

        let handlers = Self.apnsTokenHandlers
        Self.apnsTokenHandlers.removeAll()
        for handler in handlers {
            handler(token)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[APNS] Failed to register: \(error)")
    }
}
