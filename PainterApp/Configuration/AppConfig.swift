import Foundation

enum AppConfig {
    static let baseURL: URL = {
        #if DEBUG
        // Override with LOCAL_BASE_URL env var during development, e.g. http://192.168.x.x:3000
        if let override = ProcessInfo.processInfo.environment["LOCAL_BASE_URL"],
           let url = URL(string: override) {
            return url
        }
        return URL(string: "http://localhost:3000")!
        #else
        return URL(string: "https://app.liftbyai.com")!
        #endif
    }()

    static var startURL: URL {
        baseURL
    }

    static var pathConfigurationURL: URL {
        baseURL.appendingPathComponent("configurations/ios_v1.json")
    }
}
