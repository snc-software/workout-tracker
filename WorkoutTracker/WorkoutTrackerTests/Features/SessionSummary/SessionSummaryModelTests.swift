//
//  SessionSummaryModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct SessionSummaryModelTests {
    @Test func applyNewPersonalRecordsInsertsARecordForAnExerciseWithNoExistingOne() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let benchPress = Exercise(name: "Bench Press")
        context.insert(benchPress)
        let log = WorkoutLog(
            startedAt: Date(timeIntervalSince1970: 0),
            finishedAt: Date(timeIntervalSince1970: 1),
            exercises: [
                WorkoutLogExercise(
                    exercise: benchPress,
                    order: 0,
                    sets: [WorkoutSetLog(order: 0, weightKg: 60, reps: 8)]
                )
            ]
        )
        try context.save()

        let model = SessionSummaryModel(workoutLog: log)
        try model.applyNewPersonalRecords(context: context)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.exercise.name == "Bench Press")
        #expect(records.first?.weightKg == 60)
    }

    @Test func applyNewPersonalRecordsUpdatesAnExistingRecordInPlaceWhenBeaten() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let benchPress = Exercise(name: "Bench Press")
        let record = PersonalRecord(exercise: benchPress, weightKg: 80)
        context.insert(benchPress)
        context.insert(record)
        let log = WorkoutLog(
            startedAt: Date(timeIntervalSince1970: 0),
            finishedAt: Date(timeIntervalSince1970: 1),
            exercises: [
                WorkoutLogExercise(
                    exercise: benchPress,
                    order: 0,
                    sets: [WorkoutSetLog(order: 0, weightKg: 90, reps: 3)]
                )
            ]
        )
        try context.save()

        let model = SessionSummaryModel(workoutLog: log)
        try model.applyNewPersonalRecords(context: context)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 1)
        #expect(records.first?.weightKg == 90)
    }

    @Test func applyNewPersonalRecordsLeavesUnrelatedOrUnbeatenRecordsUntouched() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let benchPress = Exercise(name: "Bench Press")
        let squat = Exercise(name: "Squat")
        let benchRecord = PersonalRecord(exercise: benchPress, weightKg: 100)
        let squatRecord = PersonalRecord(exercise: squat, weightKg: 140)
        context.insert(benchPress)
        context.insert(squat)
        context.insert(benchRecord)
        context.insert(squatRecord)
        let log = WorkoutLog(
            startedAt: Date(timeIntervalSince1970: 0),
            finishedAt: Date(timeIntervalSince1970: 1),
            exercises: [
                WorkoutLogExercise(
                    exercise: benchPress,
                    order: 0,
                    sets: [WorkoutSetLog(order: 0, weightKg: 80, reps: 8)]
                )
            ]
        )
        try context.save()

        let model = SessionSummaryModel(workoutLog: log)
        try model.applyNewPersonalRecords(context: context)

        let records = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(records.count == 2)
        #expect(records.first { $0.exercise.name == "Bench Press" }?.weightKg == 100)
        #expect(records.first { $0.exercise.name == "Squat" }?.weightKg == 140)
    }
}
