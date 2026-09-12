//
//  WorkoutTrackerUITests.swift
//  WorkoutTrackerUITests
//
//  Created by Scott Crowther on 12/09/2026.
//

import XCTest

final class WorkoutTrackerUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests
        // before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTabBarShowsAllDestinations() {
        let app = XCUIApplication()
        app.launch()

        // Note: SwiftUI's `Tab(value:content:label:)` does not propagate
        // `.accessibilityIdentifier` to the rendered tab bar button on this
        // SDK, so tabs are located by their (localized) label text instead.
        let destinations = [
            (tab: "Dashboard", screen: "screen.dashboard"),
            (tab: "Schedule", screen: "screen.schedule"),
            (tab: "Exercises", screen: "screen.exercises"),
            (tab: "More", screen: "screen.more")
        ]

        for destination in destinations {
            XCTAssertTrue(app.tabBars.buttons[destination.tab].waitForExistence(timeout: 5))
        }

        for destination in destinations {
            app.tabBars.buttons[destination.tab].tap()
            XCTAssertTrue(app.descendants(matching: .any)[destination.screen].waitForExistence(timeout: 2))
        }
    }

    @MainActor
    func testLaunchPerformance() {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
