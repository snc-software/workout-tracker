//
//  GreetingPeriodTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct GreetingPeriodTests {
    @Test(arguments: [0, 6, 11])
    func hoursBeforeNoonMapToMorning(hour: Int) {
        #expect(GreetingPeriod(hour: hour) == .morning)
    }

    @Test(arguments: [12, 14, 16])
    func hoursFromNoonToBeforeFivePMMapToAfternoon(hour: Int) {
        #expect(GreetingPeriod(hour: hour) == .afternoon)
    }

    @Test(arguments: [17, 20, 23])
    func hoursFromFivePMOnwardsMapToEvening(hour: Int) {
        #expect(GreetingPeriod(hour: hour) == .evening)
    }
}
