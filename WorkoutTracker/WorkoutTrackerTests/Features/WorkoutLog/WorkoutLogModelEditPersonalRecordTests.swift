//
//  WorkoutLogModelEditPersonalRecordTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct WorkoutLogModelEditPersonalRecordTests {
    private let benchPress = Exercise(name: "Bench Press")
    private let squat = Exercise(name: "Squat")

    @discardableResult
    private func saveOneExerciseOneSetLog(
        exercise: Exercise,
        weightKg: Double,
        context: ModelContext,
        startedAt: Date,
        finishedAt: Date
    ) throws -> WorkoutLog {
        let model = WorkoutLogModel(source: .custom, startedAt: startedAt)
        model.addExercise(exercise)
        model.entries[0].sets[0].weightKg = weightKg
        model.entries[0].sets[0].reps = 5
        return try model.save(context: context, finishedAt: finishedAt)
    }

    @Test func editingUpWhileThisLogAlreadyHoldsTheRecordUpdatesItsWeight() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try saveOneExerciseOneSetLog(
            exercise: benchPress,
            weightKg: 80,
            context: context,
            startedAt: Date(timeIntervalSince1970: 1000),
            finishedAt: Date(timeIntervalSince1970: 2000)
        )

        let model = WorkoutLogModel(editing: log)
        model.entries[0].sets[0].weightKg = 90
        let newFinishedAt = Date(timeIntervalSince1970: 3000)

        try model.save(context: context, finishedAt: newFinishedAt)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 90)
        #expect(records.first?.achievedAt == newFinishedAt)
        #expect(records.first?.achievedInWorkout?.id == log.id)
        #expect(log.exercises.first?.personalRecordWeightKg == 90)
    }

    @Test(arguments: [
        (50.0, false),
        (110.0, true)
    ])
    func editingAnExerciseThatDoesNotHoldTheRecordStillAppliesTheBeatsCheck(
        editedWeightKg: Double,
        beatsRecord: Bool
    ) throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        context.insert(squat)
        context.insert(PersonalRecord(exercise: squat, weightKg: 100, achievedAt: Date(timeIntervalSince1970: 0)))
        let log = try saveOneExerciseOneSetLog(
            exercise: squat,
            weightKg: 40,
            context: context,
            startedAt: Date(timeIntervalSince1970: 1000),
            finishedAt: Date(timeIntervalSince1970: 2000)
        )

        let model = WorkoutLogModel(editing: log)
        model.entries[0].sets[0].weightKg = editedWeightKg
        let newFinishedAt = Date(timeIntervalSince1970: 3000)

        try model.save(context: context, finishedAt: newFinishedAt)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        if beatsRecord {
            #expect(records.first?.weightKg == editedWeightKg)
            #expect(records.first?.achievedAt == newFinishedAt)
            #expect(records.first?.achievedInWorkout?.id == log.id)
            #expect(log.exercises.first?.personalRecordWeightKg == editedWeightKg)
        } else {
            #expect(records.first?.weightKg == 100)
            #expect(records.first?.achievedInWorkout == nil)
            #expect(log.exercises.first?.personalRecordWeightKg == nil)
        }
    }

    @Test func editingDownBelowAnotherLogsMaxTransfersTheRecordToThatOtherLog() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let otherLog = try saveOneExerciseOneSetLog(
            exercise: benchPress,
            weightKg: 70,
            context: context,
            startedAt: Date(timeIntervalSince1970: 0),
            finishedAt: Date(timeIntervalSince1970: 500)
        )
        let editedLog = try saveOneExerciseOneSetLog(
            exercise: benchPress,
            weightKg: 80,
            context: context,
            startedAt: Date(timeIntervalSince1970: 1000),
            finishedAt: Date(timeIntervalSince1970: 2000)
        )

        let model = WorkoutLogModel(editing: editedLog)
        model.entries[0].sets[0].weightKg = 60

        try model.save(context: context, finishedAt: Date(timeIntervalSince1970: 3000))

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 70)
        #expect(records.first?.achievedInWorkout?.id == otherLog.id)
        #expect(otherLog.exercises.first?.personalRecordWeightKg == 70)
        #expect(editedLog.exercises.first?.personalRecordWeightKg == nil)
    }

    @Test func editingDownToTheOnlyQualifyingEntryAcrossHistoryDeletesTheRecord() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try saveOneExerciseOneSetLog(
            exercise: benchPress,
            weightKg: 80,
            context: context,
            startedAt: Date(timeIntervalSince1970: 1000),
            finishedAt: Date(timeIntervalSince1970: 2000)
        )

        let model = WorkoutLogModel(editing: log)
        model.toggleSkip(model.entries[0])

        try model.save(context: context, finishedAt: Date(timeIntervalSince1970: 3000))

        #expect(try context.fetch(FetchDescriptor<PersonalRecord>()).isEmpty)
        #expect(log.exercises.first?.personalRecordWeightKg == nil)
    }
}
