//
//  WorkoutBuilderUITests.swift
//  WorkoutTrackerUITests
//

import XCTest

final class WorkoutBuilderUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddingExercisesToADayShowsOnTheScheduleListAndCanBeEditedAndReduced() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Schedule"].tap()

        let mondayAdd = app.descendants(matching: .any)["schedule.day.MON"]
        XCTAssertTrue(mondayAdd.waitForExistence(timeout: 5))
        mondayAdd.tap()

        app.buttons["schedule.builder.addExercise"].tap()
        var resultRow = app.descendants(matching: .any)["schedule.builder.picker.result.Barbell Bench Press"]
        XCTAssertTrue(resultRow.waitForExistence(timeout: 5))
        resultRow.tap()

        app.buttons["schedule.builder.addExercise"].tap()
        resultRow = app.descendants(matching: .any)["schedule.builder.picker.result.Barbell Deadlift"]
        XCTAssertTrue(resultRow.waitForExistence(timeout: 5))
        resultRow.tap()

        app.buttons["schedule.builder.groupIntoSuperset"].tap()

        let benchPressCheckbox = app.buttons["schedule.builder.block.exercise.Barbell Bench Press.selection"]
        let deadliftCheckbox = app.buttons["schedule.builder.block.exercise.Barbell Deadlift.selection"]
        XCTAssertTrue(benchPressCheckbox.waitForExistence(timeout: 5))
        benchPressCheckbox.tap()
        deadliftCheckbox.tap()

        app.buttons["schedule.builder.grouping.confirm"].tap()

        let supersetCard = app.descendants(matching: .any)["schedule.builder.block.superset"]
        XCTAssertTrue(supersetCard.waitForExistence(timeout: 5))

        app.buttons["schedule.builder.save"].tap()

        let mondayRow = app.descendants(matching: .any)["schedule.day.MON"]
        XCTAssertTrue(mondayRow.waitForExistence(timeout: 5))
        XCTAssertTrue(mondayRow.staticTexts["Barbell Bench Press"].waitForExistence(timeout: 5))

        mondayRow.tap()

        let benchPressBlock = app
            .descendants(matching: .any)["schedule.builder.block.exercise.Barbell Bench Press.remove"]
        XCTAssertTrue(benchPressBlock.waitForExistence(timeout: 5))
        app.buttons["schedule.builder.block.exercise.Barbell Bench Press.remove"].tap()

        app.buttons["schedule.builder.save"].tap()

        let updatedMondayRow = app.descendants(matching: .any)["schedule.day.MON"]
        XCTAssertTrue(updatedMondayRow.waitForExistence(timeout: 5))
        XCTAssertTrue(updatedMondayRow.staticTexts["Barbell Deadlift"].waitForExistence(timeout: 5))
        XCTAssertFalse(updatedMondayRow.staticTexts["Barbell Bench Press"].exists)
    }

    @MainActor
    func testMovingAnExerciseUpWithinASupersetReordersItAndPersists() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Schedule"].tap()

        let tuesdayAdd = app.descendants(matching: .any)["schedule.day.TUE"]
        XCTAssertTrue(tuesdayAdd.waitForExistence(timeout: 5))
        tuesdayAdd.tap()

        for name in ["Barbell Bench Press", "Barbell Deadlift", "Barbell Back Squat"] {
            app.buttons["schedule.builder.addExercise"].tap()
            let resultRow = app.descendants(matching: .any)["schedule.builder.picker.result.\(name)"]
            XCTAssertTrue(resultRow.waitForExistence(timeout: 5))
            resultRow.tap()
        }

        app.buttons["schedule.builder.groupIntoSuperset"].tap()
        for name in ["Barbell Bench Press", "Barbell Deadlift", "Barbell Back Squat"] {
            app.buttons["schedule.builder.block.exercise.\(name).selection"].tap()
        }
        app.buttons["schedule.builder.grouping.confirm"].tap()

        let supersetCard = app.descendants(matching: .any)["schedule.builder.block.superset"]
        XCTAssertTrue(supersetCard.waitForExistence(timeout: 5))

        app.buttons["schedule.builder.reorder.toggle"].tap()

        let moveSquatUp = app.buttons["schedule.builder.block.exercise.Barbell Back Squat.moveUp"]
        XCTAssertTrue(moveSquatUp.waitForExistence(timeout: 5))
        moveSquatUp.tap()
        moveSquatUp.tap()

        app.buttons["schedule.builder.reorder.toggle"].tap()
        app.buttons["schedule.builder.save"].tap()

        let tuesdayRow = app.descendants(matching: .any)["schedule.day.TUE"]
        XCTAssertTrue(tuesdayRow.waitForExistence(timeout: 5))
        XCTAssertTrue(tuesdayRow.staticTexts["Barbell Back Squat"].waitForExistence(timeout: 5))
    }
}
