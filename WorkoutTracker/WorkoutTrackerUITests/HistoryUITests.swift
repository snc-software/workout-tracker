//
//  HistoryUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

/// Generous relative to the other UI test files, for the same reason as `WorkoutLogUITests`: this flow
/// passes through a full "finish a workout" journey before History even opens.
private let waitTimeout: TimeInterval = 15

final class HistoryUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFinishingAWorkoutThenOpeningItFromHistoryShowsSummaryAndBackReturnsToHistory() {
        let app = XCUIApplication()
        app.launch()

        let startWorkoutButton = app.buttons["dashboard.startWorkoutButton"]
        XCTAssertTrue(startWorkoutButton.waitForExistence(timeout: waitTimeout))
        startWorkoutButton.tap()

        let customOption = app.descendants(matching: .any)["startWorkout.custom"]
        XCTAssertTrue(customOption.waitForExistence(timeout: waitTimeout))
        customOption.tap()

        let logScreen = app.descendants(matching: .any)["screen.workoutLog"]
        XCTAssertTrue(logScreen.waitForExistence(timeout: waitTimeout))

        app.buttons["workoutLog.addExercise"].tap()

        let resultRow = app.descendants(matching: .any)["workoutLog.picker.result.Barbell Bench Press"]
        XCTAssertTrue(resultRow.waitForExistence(timeout: waitTimeout))
        resultRow.tap()

        XCTAssertTrue(app.staticTexts["Barbell Bench Press"].waitForExistence(timeout: waitTimeout))

        let weightField = app.textFields["Weight in kilograms"]
        XCTAssertTrue(weightField.waitForExistence(timeout: waitTimeout))
        weightField.tap()
        weightField.typeText("60")

        let repsField = app.textFields["Reps"]
        XCTAssertTrue(repsField.waitForExistence(timeout: waitTimeout))
        repsField.tap()
        repsField.typeText("5")

        app.buttons["workoutLog.finish"].tap()

        let summaryScreen = app.descendants(matching: .any)["screen.sessionSummary"]
        XCTAssertTrue(summaryScreen.waitForExistence(timeout: waitTimeout))
        app.buttons["sessionSummary.finish"].tap()

        let dashboardScreen = app.descendants(matching: .any)["screen.dashboard"]
        XCTAssertTrue(dashboardScreen.waitForExistence(timeout: waitTimeout))

        app.buttons["dashboard.historyButton"].tap()

        let historyScreen = app.descendants(matching: .any)["screen.history"]
        XCTAssertTrue(historyScreen.waitForExistence(timeout: waitTimeout))

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
}
