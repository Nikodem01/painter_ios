import HotwireNative
import UIKit

final class MainNavigator {
    let navigator = Navigator()

    init() {
        configureBridgeComponents()
        configurePathConfiguration()
    }

    func start(in window: UIWindow) {
        window.rootViewController = navigator.rootViewController
        navigator.route(AppConfig.startURL)
    }

    // MARK: - Private

    private func configureBridgeComponents() {
        BridgeComponent.register([
            PushRegistrationComponent.self,
            AudioPlayerComponent.self,
            CallInitiateComponent.self,
        ])
    }

    private func configurePathConfiguration() {
        navigator.pathConfiguration = PathConfiguration(sources: [
            .file(Bundle.main.url(forResource: "path-configuration", withExtension: "json")),
            .server(AppConfig.pathConfigurationURL),
        ].compactMap { $0 })
    }
}
