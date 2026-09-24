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
        let gap = app.tabBars.firstMatch.frame.minY - toastCard.frame.maxY
        XCTAssertGreaterThanOrEqual(gap, 26, "The rear cards must also clear the tab bar.")
        XCTAssertLessThanOrEqual(gap, 30, "Apply the content safe area only once.")
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
        XCTAssertLessThan(topCard.frame.minY, app.navigationBars["Home"].frame.maxY)
        topCard.buttons["Dismiss toast"].tap()
        XCTAssertTrue(app.staticTexts["Toast 5"].exists)
        XCTAssertTrue(app.staticTexts["5 active toasts"].exists)
    }

    func testBindingToastsResetBindingsAndRefreshCustomContent() {
        launchApp()
        tapButton(named: "Binding-based toasts")
        XCTAssertTrue(app.navigationBars["Binding toasts"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Show custom toast"].waitForExistence(timeout: 3))
        tapButton(named: "Show custom toast")
        XCTAssertTrue(app.staticTexts["Custom count: 0"].waitForExistence(timeout: 3))
        app.buttons["Increment"].tap()
        XCTAssertTrue(app.staticTexts["Custom count: 1"].exists)
        app.buttons["Close custom toast"].tap()
        XCTAssertTrue(app.staticTexts["Custom binding: false"].exists)
        XCTAssertTrue(app.staticTexts["Dismissals: 1"].exists)

        tapButton(named: "Show enum toast")
        XCTAssertTrue(app.staticTexts["Bound toast"].waitForExistence(timeout: 3))
        XCTAssertEqual(toastCard.frame.minY - app.navigationBars["Binding toasts"].frame.maxY, 12, accuracy: 1)
        tapButton(named: "Update enum toast")
        XCTAssertTrue(app.staticTexts["Updated bound toast"].waitForExistence(timeout: 3))
        toastCard.swipeLeft()
        XCTAssertTrue(app.staticTexts["Enum binding: nil"].exists)
        XCTAssertTrue(app.staticTexts["Dismissals: 2"].exists)

        let expirationSwitch = app.switches["Expire automatically"]
        expirationSwitch.switches.firstMatch.tap()
        XCTAssertEqual(expirationSwitch.value as? String, "1")
        tapButton(named: "Show custom toast")
        XCTAssertTrue(app.staticTexts["Custom binding: true"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["Custom binding: false"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Dismissals: 3"].exists)

        tapButton(named: "Show saved toast")
        XCTAssertTrue(app.staticTexts["Saved"].waitForExistence(timeout: 2))
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Boolean enum binding: false"].exists)
        XCTAssertTrue(app.staticTexts["Dismissals: 4"].exists)

        tapButton(named: "Show saved toast")
        XCTAssertTrue(app.staticTexts["Saved"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Boolean enum binding: false"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Dismissals: 5"].exists)
    }

    func testToastPlacementCanChangeWithoutResettingOccurrences() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        XCTAssertTrue(app.staticTexts["Toast 5"].waitForExistence(timeout: 3))
        let automaticBottom = toastCard.frame.maxY

        app.buttons["Container"].tap()
        XCTAssertGreaterThan(toastCard.frame.maxY, automaticBottom + 20)
        XCTAssertTrue(app.staticTexts["Toast 5"].exists)
        app.buttons["Content"].tap()
        XCTAssertEqual(toastCard.frame.maxY, automaticBottom, accuracy: 1)

        tapButton(named: "Show a top error")
        let topCard = app.descendants(matching: .any)
            .matching(identifier: "toast-card")
            .containing(.staticText, identifier: "Upload failed")
            .firstMatch
        XCTAssertTrue(topCard.waitForExistence(timeout: 3))
        XCTAssertEqual(topCard.frame.minY, app.navigationBars["Home"].frame.maxY + 12, accuracy: 1)
        app.buttons["Automatic"].tap()
        XCTAssertLessThan(topCard.frame.minY, app.navigationBars["Home"].frame.maxY)
        XCTAssertTrue(app.staticTexts["Toast 5"].exists)

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Automatic toast placement"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        topCard.buttons["Dismiss toast"].tap()
        XCTAssertTrue(app.staticTexts["5 active toasts"].exists)
    }

    func testToastSafeAreaFollowsSelectedRootAndCustomBar() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        selectRoot(named: "Library")
        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.tabBars.firstMatch.frame.minY - toastCard.frame.maxY, 28, accuracy: 1)
        tapButton(named: "Article 1")
        XCTAssertTrue(app.navigationBars["Article 1"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.tabBars.firstMatch.frame.minY - toastCard.frame.maxY, 28, accuracy: 1)
        app.buttons["Custom view"].tap()
        let rootBar = app.scrollViews["custom-root-bar"]
        XCTAssertTrue(rootBar.waitForExistence(timeout: 3))
        XCTAssertGreaterThanOrEqual(rootBar.frame.minY - toastCard.frame.maxY, 26)
        XCTAssertLessThanOrEqual(rootBar.frame.minY - toastCard.frame.maxY, 31)
    }

    func testToastDeckClearsTheKeyboardInEveryPlacement() {
        launchApp()
        tapButton(named: "Stack five persistent toasts")
        selectRoot(named: "Search")
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        searchField.tap()
        let keyboard = app.keyboards.firstMatch
        XCTAssertTrue(keyboard.waitForExistence(timeout: 3))

        for placement in ["Automatic", "Container", "Content"] {
            app.buttons[placement].tap()
            XCTAssertTrue(keyboard.exists)
            XCTAssertTrue(app.staticTexts["Toast 5"].exists)
            XCTAssertGreaterThanOrEqual(keyboard.frame.minY - toastCard.frame.maxY, 26)
        }
        searchField.typeText("42")
        XCTAssertEqual(searchField.value as? String, "42")
        dismissToastButton.tap()
        XCTAssertTrue(app.staticTexts["Toast 4"].waitForExistence(timeout: 3))
        XCTAssertTrue(keyboard.exists)
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
