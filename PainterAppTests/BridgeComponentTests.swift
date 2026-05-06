import XCTest
@testable import PainterApp

final class BridgeComponentTests: XCTestCase {
    func testCallInitiateComponentName() {
        XCTAssertEqual(CallInitiateComponent.name, "call-initiate")
    }

    func testAudioPlayerComponentName() {
        XCTAssertEqual(AudioPlayerComponent.name, "audio-player")
    }

    func testPushRegistrationComponentName() {
        XCTAssertEqual(PushRegistrationComponent.name, "push-registration")
    }
}
