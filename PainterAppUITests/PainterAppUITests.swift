import XCTest

final class PainterAppUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAppLaunches() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
}
