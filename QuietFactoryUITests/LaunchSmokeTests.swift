import XCTest

final class LaunchSmokeTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchShowsChrome() throws {
        let app = XCUIApplication()
        app.launch()

        let title = app.staticTexts["quiet-factory-title"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Expected Quiet Factory title")

        let restart = app.buttons["restart-button"]
        XCTAssertTrue(restart.waitForExistence(timeout: 5), "Expected RESTART button")

        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        attachment.name = "LaunchSmoke"
        add(attachment)
    }
}
