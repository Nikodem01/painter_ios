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

    func testTelURLStripsUSFormatting() {
        let url = CallInitiateComponent.telURL(for: "+1 (555) 123-4567")
        XCTAssertEqual(url?.absoluteString, "tel://15551234567")
    }

    func testTelURLStripsInternationalFormatting() {
        let url = CallInitiateComponent.telURL(for: "+44 20 7946 0958")
        XCTAssertEqual(url?.absoluteString, "tel://442079460958")
    }

    func testTelURLAcceptsOnlyDigitsInput() {
        let url = CallInitiateComponent.telURL(for: "5551234567")
        XCTAssertEqual(url?.absoluteString, "tel://5551234567")
    }

    func testTelURLRejectsEmptyString() {
        XCTAssertNil(CallInitiateComponent.telURL(for: ""))
    }

    func testTelURLRejectsNonDigitOnlyString() {
        XCTAssertNil(CallInitiateComponent.telURL(for: "no digits here"))
    }
}
