import XCTest

@MainActor
final class PresentationDirectionTests: XCTestCase {
    func testArabicSheetAndNestedCover() {
        verifyPresentations(rightToLeft: true, first: "sheet", nested: "cover")
    }

    func testArabicCoverAndNestedSheet() {
        verifyPresentations(rightToLeft: true, first: "cover", nested: "sheet")
    }

    func testEnglishSheetAndNestedCover() {
        verifyPresentations(rightToLeft: false, first: "sheet", nested: "cover")
    }

    func testEnglishCoverAndNestedSheet() {
        verifyPresentations(rightToLeft: false, first: "cover", nested: "sheet")
    }

    private func verifyPresentations(rightToLeft: Bool, first: String, nested: String) {
        continueAfterFailure = false
        let app = XCUIApplication()
        // Deliberately oppose the system language to model in-app language selection.
        app.launchArguments = ["--presentation-direction", "-AppleLanguages", rightToLeft ? "(en)" : "(ar)", "-AppleLocale", rightToLeft ? "en_US" : "ar_IQ"]
        if rightToLeft { app.launchArguments.append("--rtl") }
        app.launch()

        assertDirection(in: app, depth: 0, rightToLeft: rightToLeft)
        let started = Date()
        app.buttons["show-0"].tap()
        XCTAssertTrue(app.staticTexts["leading-toast"].waitForExistence(timeout: 3))
        let snapshot = app.staticTexts["occurrences-0"].label
        XCTAssertNotEqual(snapshot, "none")
        assertToasts(in: app, rightToLeft: rightToLeft)

        app.buttons["\(first)-0"].tap()
        assertDirection(in: app, depth: 1, rightToLeft: rightToLeft)
        XCTAssertEqual(app.staticTexts["occurrences-1"].label, snapshot)
        assertToasts(in: app, rightToLeft: rightToLeft)

        app.buttons["\(nested)-1"].tap()
        assertDirection(in: app, depth: 2, rightToLeft: rightToLeft)
        XCTAssertEqual(app.staticTexts["occurrences-2"].label, snapshot)
        assertToasts(in: app, rightToLeft: rightToLeft)

        // Both original deadlines must expire while the nested presentation remains visible.
        let expired = NSPredicate(format: "label == 'none'")
        expectation(for: expired, evaluatedWith: app.staticTexts["occurrences-2"])
        waitForExpectations(timeout: max(1, 23 - Date().timeIntervalSince(started)))
        XCTAssertFalse(app.staticTexts["leading-toast"].exists)
        XCTAssertFalse(app.staticTexts["trailing-toast"].exists)
        app.buttons["dismiss-2"].tap()
        assertDirection(in: app, depth: 1, rightToLeft: rightToLeft)
        app.buttons["dismiss-1"].tap()
        assertDirection(in: app, depth: 0, rightToLeft: rightToLeft)
        XCTAssertEqual(app.staticTexts["occurrences-0"].label, "none")
    }

    private func assertDirection(in app: XCUIApplication, depth: Int, rightToLeft: Bool) {
        let direction = app.staticTexts["direction-\(depth)"]
        XCTAssertTrue(direction.waitForExistence(timeout: 3))
        XCTAssertEqual(direction.label, rightToLeft ? "RTL" : "LTR")
        XCTAssertEqual(app.staticTexts["locale-\(depth)"].label, rightToLeft ? "ar_IQ" : "en_US")
        let leading = app.staticTexts["leading-\(depth)"].frame.midX
        let trailing = app.staticTexts["trailing-\(depth)"].frame.midX
        XCTAssertEqual(leading > trailing, rightToLeft)
    }

    private func assertToasts(in app: XCUIApplication, rightToLeft: Bool) {
        let leading = app.staticTexts["leading-toast"]
        let trailing = app.staticTexts["trailing-toast"]
        XCTAssertTrue(leading.exists)
        XCTAssertTrue(trailing.exists)
        XCTAssertEqual(leading.value as? String, rightToLeft ? "RTL" : "LTR")
        XCTAssertEqual(trailing.value as? String, rightToLeft ? "RTL" : "LTR")
        XCTAssertEqual(leading.label, rightToLeft ? "تم الحفظ" : "Saved")
        XCTAssertEqual(leading.frame.midX > trailing.frame.midX, rightToLeft)
        XCTAssertGreaterThanOrEqual(leading.frame.minX, app.frame.minX)
        XCTAssertLessThanOrEqual(leading.frame.maxX, app.frame.maxX)
    }
}
