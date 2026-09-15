//
//  WorkoutLogModelEditTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct WorkoutLogModelEditTests {
    private let benchPress = Exercise(name: "Bench Press")
    private let squat = Exercise(name: "Squat")

    @discardableResult
    private func makeSavedLog(
        context: ModelContext,
        startedAt: Date = Date(timeIntervalSince1970: 1000),
        finishedAt: Date = Date(timeIntervalSince1970: 2000)
    ) throws -> WorkoutLog {
        let model = WorkoutLogModel(source: .custom, startedAt: startedAt)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 60
        model.entries[0].sets[0].reps = 5
        model.addSet(to: model.entries[0])
        model.entries[0].sets[1].weightKg = 65
        model.entries[0].sets[1].reps = 3
        return try model.save(context: context, finishedAt: finishedAt)
    }

    private func sortedSets(_ entry: WorkoutLogExercise) -> [WorkoutSetLog] {
        entry.sets.sorted { $0.order < $1.order }
    }

    @Test func initEditingSnapshotsExercisesSetsAndDatesFromTheLog() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let startedAt = Date(timeIntervalSince1970: 1000)
        let finishedAt = Date(timeIntervalSince1970: 2000)
        let log = try makeSavedLog(context: context, startedAt: startedAt, finishedAt: finishedAt)

        let model = WorkoutLogModel(editing: log)

        #expect(model.startedAt == startedAt)
        #expect(model.entries.count == 1)
        #expect(model.entries[0].exercise == benchPress)
        #expect(sortedSets(model.entries[0]).map(\.weightKg) == [60, 65])
        #expect(sortedSets(model.entries[0]).map(\.reps) == [5, 3])
    }

    @Test func editingDraftEntriesAreDetachedFromTheLiveModelContext() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)

        let model = WorkoutLogModel(editing: log)

        #expect(model.entries[0].modelContext == nil)
        #expect(model.entries[0].sets[0].modelContext == nil)
    }

    @Test func mutatingTheDraftAfterInitDoesNotChangeThePersistedLogOrItsSetsUntilSave() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)
        let originalWeightKg = sortedSets(log.exercises[0])[0].weightKg
        let originalSetCount = log.exercises[0].sets.count

        let model = WorkoutLogModel(editing: log)
        let draftEntry = model.entries[0]
        sortedSets(draftEntry)[0].weightKg = 999
        model.removeSet(sortedSets(draftEntry)[1], from: draftEntry)

        #expect(sortedSets(log.exercises[0])[0].weightKg == originalWeightKg)
        #expect(log.exercises[0].sets.count == originalSetCount)
    }

    @Test func saveUpdatesTheExistingLogInPlaceRatherThanInsertingADuplicate() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)
        let originalID = log.id

        let model = WorkoutLogModel(editing: log)
        sortedSets(model.entries[0])[0].weightKg = 70

        let savedLog = try model.save(context: context, finishedAt: log.finishedAt ?? Date())

        let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(savedLog.id == originalID)
        #expect(sortedSets(logs[0].exercises[0])[0].weightKg == 70)
    }

    @Test func saveInsertsANewlyAddedSetAndDeletesARemovedSet() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)
        let removedSetID = sortedSets(log.exercises[0])[1].id

        let model = WorkoutLogModel(editing: log)
        let draftEntry = model.entries[0]
        model.removeSet(sortedSets(draftEntry)[1], from: draftEntry)
        model.addSet(to: draftEntry)
        sortedSets(draftEntry)[1].weightKg = 80
        sortedSets(draftEntry)[1].reps = 2

        try model.save(context: context, finishedAt: log.finishedAt ?? Date())

        let sets = try context.fetch(FetchDescriptor<WorkoutSetLog>())
        #expect(sets.contains { $0.id == removedSetID } == false)
        #expect(log.exercises[0].sets.count == 2)
        #expect(sortedSets(log.exercises[0]).map(\.weightKg) == [60, 80])
    }

    @Test func saveAddsANewlyAddedExercise() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)

        let model = WorkoutLogModel(editing: log)
        model.addExercise(squat)
        model.entries[1].sets[0].weightKg = 100
        model.entries[1].sets[0].reps = 5

        try model.save(context: context, finishedAt: log.finishedAt ?? Date())

        #expect(log.exercises.count == 2)
        #expect(log.exercises.map(\.exercise).contains(squat))
    }

    @Test func saveMutatesStartedAtAndFinishedAtOnTheExistingLog() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let log = try makeSavedLog(context: context)
        let newStartedAt = Date(timeIntervalSince1970: 500)
        let newFinishedAt = Date(timeIntervalSince1970: 3000)

        let model = WorkoutLogModel(editing: log)
        model.startedAt = newStartedAt

        try model.save(context: context, finishedAt: newFinishedAt)

        #expect(log.startedAt == newStartedAt)
        #expect(log.finishedAt == newFinishedAt)
    }
}
