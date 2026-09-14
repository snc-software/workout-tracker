//
//  RecordsModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
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

    @Test func deleteRecordRemovesItFromTheContext() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = RecordsModel()
        let record = PersonalRecord(exercise: Exercise(name: "Bench Press"), weightKg: 82.5)
        context.insert(record)
        try context.save()

        try model.deleteRecord(record, context: context)

        let all = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(all.isEmpty)
    }
}
