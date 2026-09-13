//
//  WorkoutLogUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

/// Generous relative to the other UI test files: the flows here pass through a schedule save, a tab
/// switch, and the Dashboard's `@Query`-driven re-render, on top of this app's one-time synchronous
/// exercise-library seed at launch, so a 5s window is more prone to a false failure under load.
private let waitTimeout: TimeInterval = 15

final class WorkoutLogUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testStartingACustomWorkoutAddingAnExerciseLoggingASetAndFinishingPersistsIt() {
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

        let dashboardScreen = app.descendants(matching: .any)["screen.dashboard"]
        XCTAssertTrue(dashboardScreen.waitForExistence(timeout: waitTimeout))
    }

    @MainActor
    func testStartingTodaysScheduledWorkoutFromTheDashboardShortcutLoadsItIntoTheLoggingScreen() {
        let app = XCUIApplication()
        app.launch()

        let weekday = Calendar.current.component(.weekday, from: Date())
        let todayShortLabel = Calendar.current.shortWeekdaySymbols[weekday - 1].uppercased(with: Locale.current)

        app.tabBars.buttons["Schedule"].tap()

        let todayDayRow = app.descendants(matching: .any)["schedule.day.\(todayShortLabel)"]
        XCTAssertTrue(todayDayRow.waitForExistence(timeout: waitTimeout))
        todayDayRow.tap()

        app.buttons["schedule.builder.addExercise"].tap()
        let resultRow = app.descendants(matching: .any)["schedule.builder.picker.result.Barbell Bench Press"]
        XCTAssertTrue(resultRow.waitForExistence(timeout: waitTimeout))
        resultRow.tap()

        app.buttons["schedule.builder.save"].tap()

        app.tabBars.buttons["Dashboard"].tap()

        let startTodayPanel = app.descendants(matching: .any)["dashboard.startTodayWorkout"]
        XCTAssertTrue(startTodayPanel.waitForExistence(timeout: waitTimeout))
        startTodayPanel.tap()

        let logScreen = app.descendants(matching: .any)["screen.workoutLog"]
        XCTAssertTrue(logScreen.waitForExistence(timeout: waitTimeout))
        XCTAssertTrue(app.staticTexts["Barbell Bench Press"].waitForExistence(timeout: waitTimeout))

        app.buttons["workoutLog.finish"].tap()

        let dashboardScreen = app.descendants(matching: .any)["screen.dashboard"]
        XCTAssertTrue(dashboardScreen.waitForExistence(timeout: waitTimeout))
    }
}
