//
//  ExercisesListUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

final class ExercisesListUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExercisesListShowsSeededExerciseAndSearchNarrowsResults() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Exercises"].tap()

        let deadliftRow = app.descendants(matching: .any)["exercise.row.Barbell Deadlift"]
        XCTAssertTrue(deadliftRow.waitForExistence(timeout: 5))

        let squatRow = app.descendants(matching: .any)["exercise.row.Barbell Back Squat"]
        XCTAssertTrue(squatRow.exists)

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Deadlift")

        XCTAssertTrue(deadliftRow.waitForExistence(timeout: 5))
        XCTAssertFalse(squatRow.exists)
    }

    @MainActor
    func testCategoryPillFiltersExercisesImmediately() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Exercises"].tap()

        let deadliftRow = app.descendants(matching: .any)["exercise.row.Barbell Deadlift"]
        XCTAssertTrue(deadliftRow.waitForExistence(timeout: 5))

        let squatRow = app.descendants(matching: .any)["exercise.row.Barbell Back Squat"]
        XCTAssertTrue(squatRow.exists)

        app.buttons["exercises.categoryFilter.Back"].tap()

        XCTAssertTrue(deadliftRow.waitForExistence(timeout: 5))
        XCTAssertFalse(squatRow.exists)

        app.buttons["exercises.categoryFilter.All"].tap()

        XCTAssertTrue(squatRow.waitForExistence(timeout: 5))
    }
}
