//
//  HistoryUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

/// Generous relative to the other UI test files, for the same reason as `WorkoutLogUITests`: these flows
/// pass through a full "log a workout" journey before History even opens.
private let waitTimeout: TimeInterval = 15

final class HistoryUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFinishingAWorkoutThenOpeningItFromHistoryShowsSummaryAndBackReturnsToHistory() {
        let app = XCUIApplication()
        app.launch()

        finishALiveCustomWorkoutAndOpenHistory(app)

        let summaryScreen = app.descendants(matching: .any)["screen.sessionSummary"]
        let historyScreen = app.descendants(matching: .any)["screen.history"]
        let historyRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'history.row.'")
        ).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: waitTimeout))
        historyRow.tap()

        XCTAssertTrue(summaryScreen.waitForExistence(timeout: waitTimeout))

        // The summary is pushed, not presented as a cover, so the system back button (not a custom
        // identifier — there's no stable way to tag it) must return to the History list rather than
        // leaving no way back.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(historyScreen.waitForExistence(timeout: waitTimeout))
    }

    @MainActor
    func testAddingAHistoricalWorkoutAppearsInHistory() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["dashboard.historyButton"].tap()
        let historyScreen = app.descendants(matching: .any)["screen.history"]
        XCTAssertTrue(historyScreen.waitForExistence(timeout: waitTimeout))

        app.buttons["history.addWorkout"].tap()

        let sourceScreen = app.descendants(matching: .any)["screen.history.addWorkout"]
        XCTAssertTrue(sourceScreen.waitForExistence(timeout: waitTimeout))
        app.buttons["history.addWorkout.custom"].tap()

        let logScreen = app.descendants(matching: .any)["screen.workoutLog"]
        XCTAssertTrue(logScreen.waitForExistence(timeout: waitTimeout))

        // Historical mode shows start/end date pickers in place of the live elapsed-timer.
        XCTAssertTrue(app.descendants(matching: .any)["workoutLog.performedAt.start"]
            .waitForExistence(timeout: waitTimeout))
        XCTAssertTrue(app.descendants(matching: .any)["workoutLog.performedAt.end"]
            .waitForExistence(timeout: waitTimeout))

        addBenchPressWithASet(app, weight: "40", reps: "10")

        app.buttons["workoutLog.finish"].tap()

        let summaryScreen = app.descendants(matching: .any)["screen.sessionSummary"]
        XCTAssertTrue(summaryScreen.waitForExistence(timeout: waitTimeout))
        app.buttons["sessionSummary.finish"].tap()

        XCTAssertTrue(historyScreen.waitForExistence(timeout: waitTimeout))
        let historyRow = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'history.row.'")
        ).firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: waitTimeout))
    }

    @MainActor
    func testSwipingAHistoryRowDeletesTheWorkout() {
        let app = XCUIApplication()
        app.launch()

        finishALiveCustomWorkoutAndOpenHistory(app)

        // Other tests in this suite may have already left rows in the persisted store (there's no
        // per-test store reset), so this asserts the swiped row specifically disappears rather than
        // asserting the whole list becomes empty.
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'history.row.'"))
        let rowCountBefore = rows.count
        let historyRow = rows.firstMatch
        XCTAssertTrue(historyRow.waitForExistence(timeout: waitTimeout))
        let deletedRowIdentifier = historyRow.identifier
        historyRow.swipeLeft()

        let deleteButton = app.buttons["history.row.delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: waitTimeout))
        // The swipe-reveal is still spring-animating into place when the accessibility tree first
        // reports the button as existing; a synthetic tap immediately after can land before the button's
        // hit-test region has caught up with its final position. A short settle avoids that race.
        Thread.sleep(forTimeInterval: 0.5)
        deleteButton.tap()

        let deletedRow = app.buttons.matching(NSPredicate(format: "identifier == %@", deletedRowIdentifier)).firstMatch
        XCTAssertTrue(deletedRow.waitForNonExistence(timeout: waitTimeout))
        XCTAssertEqual(rows.count, rowCountBefore - 1)
    }

    /// Starts a blank live workout from the Dashboard, logs one set of Bench Press, finishes it, then
    /// opens History from the Dashboard so the caller lands on `screen.history` with exactly one row.
    @MainActor
    private func finishALiveCustomWorkoutAndOpenHistory(_ app: XCUIApplication) {
        let startWorkoutButton = app.buttons["dashboard.startWorkoutButton"]
        XCTAssertTrue(startWorkoutButton.waitForExistence(timeout: waitTimeout))
        startWorkoutButton.tap()

        let customOption = app.descendants(matching: .any)["startWorkout.custom"]
        XCTAssertTrue(customOption.waitForExistence(timeout: waitTimeout))
        customOption.tap()

        let logScreen = app.descendants(matching: .any)["screen.workoutLog"]
        XCTAssertTrue(logScreen.waitForExistence(timeout: waitTimeout))

        addBenchPressWithASet(app, weight: "60", reps: "5")

        app.buttons["workoutLog.finish"].tap()

        let summaryScreen = app.descendants(matching: .any)["screen.sessionSummary"]
        XCTAssertTrue(summaryScreen.waitForExistence(timeout: waitTimeout))
        app.buttons["sessionSummary.finish"].tap()

        let dashboardScreen = app.descendants(matching: .any)["screen.dashboard"]
        XCTAssertTrue(dashboardScreen.waitForExistence(timeout: waitTimeout))

        app.buttons["dashboard.historyButton"].tap()

        let historyScreen = app.descendants(matching: .any)["screen.history"]
        XCTAssertTrue(historyScreen.waitForExistence(timeout: waitTimeout))
    }

    /// Adds Barbell Bench Press to whichever logging screen (live or historical) is currently on screen,
    /// with one set at the given weight/reps.
    @MainActor
    private func addBenchPressWithASet(_ app: XCUIApplication, weight: String, reps: String) {
        app.buttons["workoutLog.addExercise"].tap()

        let resultRow = app.descendants(matching: .any)["workoutLog.picker.result.Barbell Bench Press"]
        XCTAssertTrue(resultRow.waitForExistence(timeout: waitTimeout))
        resultRow.tap()

        XCTAssertTrue(app.staticTexts["Barbell Bench Press"].waitForExistence(timeout: waitTimeout))

        let weightField = app.textFields["Weight in kilograms"]
        XCTAssertTrue(weightField.waitForExistence(timeout: waitTimeout))
        weightField.tap()
        weightField.typeText(weight)

        let repsField = app.textFields["Reps"]
        XCTAssertTrue(repsField.waitForExistence(timeout: waitTimeout))
        repsField.tap()
        repsField.typeText(reps)
    }
}
