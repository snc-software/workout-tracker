//
//  ActiveWorkoutSessionTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct ActiveWorkoutSessionTests {
    @Test func startCreatesAModelAndExpands() {
        let session = ActiveWorkoutSession()

        session.start(source: .custom)

        #expect(session.model != nil)
        #expect(session.isExpanded)
        #expect(!session.isMinimizedPillVisible)
    }

    @Test func minimizeKeepsTheSameModelInstanceAndCollapses() {
        let session = ActiveWorkoutSession()
        session.start(source: .custom)
        let startedModel = session.model

        session.minimize()

        #expect(session.model === startedModel)
        #expect(!session.isExpanded)
        #expect(session.isMinimizedPillVisible)
    }

    @Test func maximizeReexpandsWithoutRecreatingTheModel() {
        let session = ActiveWorkoutSession()
        session.start(source: .custom)
        let startedModel = session.model
        session.minimize()

        session.maximize()

        #expect(session.model === startedModel)
        #expect(session.isExpanded)
        #expect(!session.isMinimizedPillVisible)
    }

    @Test func maximizeWithoutAnActiveModelDoesNothing() {
        let session = ActiveWorkoutSession()

        session.maximize()

        #expect(session.model == nil)
        #expect(!session.isExpanded)
    }

    @Test func endClearsTheModelAndCollapses() {
        let session = ActiveWorkoutSession()
        session.start(source: .custom)

        session.end()

        #expect(session.model == nil)
        #expect(!session.isExpanded)
        #expect(!session.isMinimizedPillVisible)
    }
}
