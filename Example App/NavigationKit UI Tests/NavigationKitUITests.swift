import XCTest

@MainActor
final class NavigationKitUITests: XCTestCase {
    private var app: XCUIApplication!

    func testNativeSelectionUpdatesTheController() {
        launchApp()

        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 5))

        selectRoot(named: "Library")
        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: 2))

        selectRoot(named: "Home")
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 2))
    }

    func testCompactNativeRootsRetainTheirNavigationPaths() throws {
        launchApp()

        if app.buttons["Toggle sidebar"].waitForExistence(timeout: 1) {
            throw XCTSkip("Root-path retention is native sidebar behavior in a regular layout.")
        }

        selectRoot(named: "Library")

        tapButton(named: "Article 1")
        XCTAssertTrue(app.navigationBars["Article 1"].waitForExistence(timeout: 2))

        selectRoot(named: "Home")
        tapButton(named: "Open Article 2 on Home")
        XCTAssertTrue(app.navigationBars["Article 2"].waitForExistence(timeout: 2))

        selectRoot(named: "Library")
        XCTAssertTrue(app.navigationBars["Article 1"].waitForExistence(timeout: 2))
    }

    func testModalDestinationUsesItsModifierAndDismisses() {
        launchApp()

        tapButton(named: "Present Article 10 as a sheet")
        XCTAssertTrue(app.navigationBars["Article 10"].waitForExistence(timeout: 2))

        tapButton(named: "Dismiss top presentation")
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.navigationBars["Article 10"].exists)
    }

    private func launchApp() {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    private func selectRoot(named name: String) {
        let button = app.buttons[name].firstMatch

        if button.waitForExistence(timeout: 1) && button.isHittable {
            button.tap()
            return
        }

        let sidebarItem = app.cells[name].firstMatch

        if !sidebarItem.exists || !sidebarItem.isHittable {
            app.buttons["Toggle sidebar"].tap()
        }

        XCTAssertTrue(
            sidebarItem.waitForExistence(timeout: 2) && sidebarItem.isHittable,
            "Expected native navigation chrome to contain the \(name) root."
        )
        sidebarItem.tap()
    }

    private func tapButton(named name: String) {
        let button = app.buttons[name]

        for _ in 0..<8 where !button.exists || !button.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(
            button.exists && button.isHittable,
            "Expected to find the \(name) button."
        )
        button.tap()
    }
}
