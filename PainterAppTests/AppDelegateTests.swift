import XCTest
@testable import PainterApp

@MainActor
final class AppDelegateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppDelegate.apnsToken = nil
        AppDelegate.apnsTokenHandlers.removeAll()
    }

    override func tearDown() {
        AppDelegate.apnsToken = nil
        AppDelegate.apnsTokenHandlers.removeAll()
        super.tearDown()
    }

    func testRequestAPNSTokenFiresHandlerImmediatelyWhenCached() {
        AppDelegate.apnsToken = "cached-token"
        var received: String?
        AppDelegate.requestAPNSToken { received = $0 }
        XCTAssertEqual(received, "cached-token")
        XCTAssertTrue(AppDelegate.apnsTokenHandlers.isEmpty)
    }

    func testRequestAPNSTokenQueuesHandlerWhenNoTokenYet() {
        var received: String?
        AppDelegate.requestAPNSToken { received = $0 }
        XCTAssertNil(received)
        XCTAssertEqual(AppDelegate.apnsTokenHandlers.count, 1)
    }

    func testDidRegisterFiresQueuedHandlersWithHexEncodedToken() {
        var first: String?
        var second: String?
        AppDelegate.requestAPNSToken { first = $0 }
        AppDelegate.requestAPNSToken { second = $0 }

        let appDelegate = AppDelegate()
        let tokenData = Data([0xab, 0xcd, 0x01, 0xff])
        appDelegate.application(.shared, didRegisterForRemoteNotificationsWithDeviceToken: tokenData)

        XCTAssertEqual(first, "abcd01ff")
        XCTAssertEqual(second, "abcd01ff")
        XCTAssertEqual(AppDelegate.apnsToken, "abcd01ff")
        XCTAssertTrue(AppDelegate.apnsTokenHandlers.isEmpty)
    }

    func testDidRegisterCachesTokenForFutureRequests() {
        let appDelegate = AppDelegate()
        let tokenData = Data([0x01, 0x02, 0x03])
        appDelegate.application(.shared, didRegisterForRemoteNotificationsWithDeviceToken: tokenData)

        var received: String?
        AppDelegate.requestAPNSToken { received = $0 }
        XCTAssertEqual(received, "010203", "request after registration should fire immediately from cache")
    }
}
