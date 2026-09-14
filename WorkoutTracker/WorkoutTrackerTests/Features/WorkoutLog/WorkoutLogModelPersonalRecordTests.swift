//
//  WorkoutLogModelPersonalRecordTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct WorkoutLogModelPersonalRecordTests {
    private let benchPress = Exercise(name: "Bench Press")

    @Test func saveInsertsAPersonalRecordDatedToFinishedAtWhenTheExerciseHadNoExistingRecord() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let finishedAt = Date(timeIntervalSince1970: 2000)
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 60
        model.entries[0].sets[0].reps = 5

        let log = try model.save(context: context, finishedAt: finishedAt)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 60)
        #expect(records.first?.achievedAt == finishedAt)
        #expect(records.first?.achievedInWorkout?.id == log.id)
        #expect(log.exercises.first?.personalRecordWeightKg == 60)
    }

    @Test func saveUpdatesAnExistingRecordInPlaceWhenBeatenAndStampsTheNewAchievedAt() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        context.insert(benchPress)
        let existingRecord = PersonalRecord(
            exercise: benchPress,
            weightKg: 80,
            achievedAt: Date(timeIntervalSince1970: 0)
        )
        context.insert(existingRecord)
        let finishedAt = Date(timeIntervalSince1970: 2000)
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 90
        model.entries[0].sets[0].reps = 3

        let log = try model.save(context: context, finishedAt: finishedAt)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 90)
        #expect(records.first?.achievedAt == finishedAt)
        #expect(records.first?.achievedInWorkout?.id == log.id)
        #expect(log.exercises.first?.personalRecordWeightKg == 90)
    }

    @Test func saveLeavesTheRecordAndTheEntryUntouchedWhenNotBeaten() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        context.insert(benchPress)
        let achievedAt = Date(timeIntervalSince1970: 0)
        context.insert(PersonalRecord(exercise: benchPress, weightKg: 100, achievedAt: achievedAt))
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 80
        model.entries[0].sets[0].reps = 8

        let log = try model.save(context: context, finishedAt: Date(timeIntervalSince1970: 2000))

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 100)
        #expect(records.first?.achievedAt == achievedAt)
        #expect(records.first?.achievedInWorkout == nil)
        #expect(log.exercises.first?.personalRecordWeightKg == nil)
    }

    @Test func saveIgnoresSkippedExercisesWhenApplyingPersonalRecords() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 90
        model.entries[0].sets[0].reps = 3
        model.toggleSkip(model.entries[0])

        let log = try model.save(context: context)

        #expect(try context.fetch(FetchDescriptor<PersonalRecord>()).isEmpty)
        #expect(log.exercises.first?.personalRecordWeightKg == nil)
    }
}
