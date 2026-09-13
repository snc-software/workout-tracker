//
//  HistoryModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import Testing
@testable import WorkoutTracker

@MainActor
struct HistoryModelTests {
    @Test func completedWorkoutsExcludesWorkoutsWithNoFinishedDate() {
        let model = HistoryModel()
        let finished = WorkoutLog(startedAt: .now, finishedAt: .now, name: "Bench Press")
        let inProgress = WorkoutLog(startedAt: .now, finishedAt: nil, name: "Squat")

        let completed = model.completedWorkouts(from: [finished, inProgress])

        #expect(completed.map(\.name) == ["Bench Press"])
    }

    @Test func completedWorkoutsOrdersByFinishedDateDescending() {
        let model = HistoryModel()
        let oldest = WorkoutLog(startedAt: .now, finishedAt: Date(timeIntervalSince1970: 1), name: "Squat")
        let newest = WorkoutLog(startedAt: .now, finishedAt: Date(timeIntervalSince1970: 3), name: "Bench Press")
        let middle = WorkoutLog(startedAt: .now, finishedAt: Date(timeIntervalSince1970: 2), name: "Deadlift")

        let completed = model.completedWorkouts(from: [oldest, newest, middle])

        #expect(completed.map(\.name) == ["Bench Press", "Deadlift", "Squat"])
    }

    @Test func completedWorkoutsOnEmptyInputReturnsEmpty() {
        let model = HistoryModel()

        #expect(model.completedWorkouts(from: []).isEmpty)
    }
}
