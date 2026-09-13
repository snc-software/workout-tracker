//
//  RecordsModelTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct RecordsModelTests {
    @Test func sortedRecordsOrdersByExerciseName() {
        let model = RecordsModel()
        let squat = PersonalRecord(exercise: Exercise(name: "Squat"), weightKg: 100)
        let benchPress = PersonalRecord(exercise: Exercise(name: "Bench Press"), weightKg: 82.5)
        let deadlift = PersonalRecord(exercise: Exercise(name: "Deadlift"), weightKg: 140)

        let sorted = model.sortedRecords(from: [squat, benchPress, deadlift])

        #expect(sorted.map(\.exercise.name) == ["Bench Press", "Deadlift", "Squat"])
    }

    @Test func sortedRecordsOnEmptyInputReturnsEmpty() {
        let model = RecordsModel()

        #expect(model.sortedRecords(from: []).isEmpty)
    }
}
