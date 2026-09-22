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

    func testToastDeckPromotesHiddenCardsAndPreservesButtons() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        XCTAssertTrue(app.staticTexts["Toast 5"].waitForExistence(timeout: 3))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Collapsed toast deck"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        XCTAssertFalse(app.staticTexts["Toast 4"].isHittable)
        XCTAssertEqual(app.buttons.matching(identifier: "Dismiss toast").allElementsBoundByIndex.filter(\.isEnabled).count, 1)

        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        toastCard.swipeLeft()
        XCTAssertTrue(app.staticTexts["Toast 3"].waitForExistence(timeout: 3))
        toastCard.swipeRight()
        XCTAssertTrue(app.staticTexts["Toast 2"].waitForExistence(timeout: 3))
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 1"].waitForExistence(timeout: 3))
        dismissToastButton.tap()
        XCTAssertFalse(app.staticTexts["Toast 1"].exists)
    }

    func testToastOverlayPassesInputAndUpdatesExistingContent() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        tapButton(named: "Update the latest toast")
        XCTAssertTrue(app.staticTexts["Saved"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["5 active toasts"].exists)
        tapButton(named: "Dismiss all toasts")
        XCTAssertTrue(app.staticTexts["0 active toasts"].exists)
    }

    func testToastDeckFollowsNativeAndCustomModalSurfaces() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        tapButton(named: "Present Article 10 as a sheet")
        XCTAssertTrue(app.navigationBars["Article 10"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 5"].waitForExistence(timeout: 3))
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        tapButton(named: "Dismiss top presentation")
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))

        app.buttons["Custom view"].tap()
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        tapButton(named: "Present Article 10 as a sheet")
        XCTAssertTrue(app.navigationBars["Article 10"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 3"].waitForExistence(timeout: 3))
    }

    func testToastDeckSurvivesNestedFullScreenPresentations() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        tapButton(named: "Present Player 1 full screen")
        XCTAssertTrue(app.navigationBars["Player 1"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 5"].waitForExistence(timeout: 3))
        tapButton(named: "Present player details")
        XCTAssertTrue(app.navigationBars["Article 1"].waitForExistence(timeout: 3))
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        tapButton(named: "Dismiss top presentation")
        XCTAssertTrue(app.navigationBars["Player 1"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        tapButton(named: "Dismiss top presentation")
        XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
    }

    func testTopAndBottomDecksAreIndependent() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        tapButton(named: "Show a top error")
        XCTAssertTrue(app.staticTexts["Upload failed"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Toast 5"].exists)
        let topCard = app.descendants(matching: .any)
            .matching(identifier: "toast-card")
            .containing(.staticText, identifier: "Upload failed")
            .firstMatch
        topCard.buttons["Dismiss toast"].tap()
        XCTAssertTrue(app.staticTexts["Toast 5"].exists)
        XCTAssertTrue(app.staticTexts["5 active toasts"].exists)
    }

    private var toastCard: XCUIElement {
        let cards = app.descendants(matching: .any).matching(identifier: "toast-card")
        guard let front = cards.allElementsBoundByIndex.last(where: \.isHittable) else {
            XCTFail("Expected an interactive front toast")
            return cards.firstMatch
        }
        return front
    }

    private var dismissToastButton: XCUIElement {
        let buttons = app.buttons.matching(identifier: "Dismiss toast")
        guard let button = buttons.allElementsBoundByIndex.first(where: \.isEnabled) else {
            XCTFail("Expected an enabled toast dismissal button")
            return buttons.firstMatch
        }
        return button
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
        let buttons = app.buttons.matching(identifier: name)

        for _ in 0..<18 {
            if let button = buttons.allElementsBoundByIndex.first(where: \.isHittable) {
                button.tap()
                return
            }
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
            start.press(forDuration: 0.01, thenDragTo: end)
        }

        XCTFail("Expected to find the \(name) button.")
    }
}
