import HotwireNative
import UIKit

@MainActor
final class MainNavigator {
    private let navigator: Navigator

    init() {
        Hotwire.registerBridgeComponents([
            PushRegistrationComponent.self,
            AudioPlayerComponent.self,
            CallInitiateComponent.self,
        ])

        Hotwire.loadPathConfiguration(from: [
            .server(AppConfig.pathConfigurationURL),
        ])

        navigator = Navigator(
            configuration: Navigator.Configuration(
                name: "main",
                startLocation: AppConfig.startURL
            )
        )
    }

    func start(in window: UIWindow) {
        window.rootViewController = navigator.rootViewController
        navigator.start()
    }
}
