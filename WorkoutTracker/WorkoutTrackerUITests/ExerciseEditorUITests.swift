//
//  ExerciseEditorUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

final class ExerciseEditorUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddingAnExerciseFromTheListAppearsInTheList() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Exercises"].tap()

        app.buttons["exercises.addButton"].tap()

        let nameField = app.descendants(matching: .any)["exercises.editor.name.field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Cable Face Pull")

        app.buttons["exercises.editor.save"].tap()

        let newRow = app.descendants(matching: .any)["exercise.row.Cable Face Pull"]
        XCTAssertTrue(newRow.waitForExistence(timeout: 5))
    }
}
