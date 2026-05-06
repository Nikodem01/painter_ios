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

    func testTelURLStripsNonDigits() {
        let url = CallInitiateComponent.telURL(for: "+1 (555) 123-4567")
        XCTAssertEqual(url?.absoluteString, "tel://15551234567")
    }

    func testTelURLRejectsEmptyDigits() {
        XCTAssertNil(CallInitiateComponent.telURL(for: "no digits here"))
    }
}
