//
//  WorkoutLogModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct WorkoutLogModelTests {
    private let benchPress = Exercise(name: "Bench Press")
    private let squat = Exercise(name: "Squat")
    private let deadlift = Exercise(name: "Deadlift")

    @Test func initWithScheduledSourceSnapshotsEachExerciseWithOneEmptySetAndNoLiveLinkToTheWorkout() {
        let workout = ScheduledWorkout(dayOfWeek: .monday, name: "Push Day")
        workout.exercises = [
            ScheduledWorkoutExercise(exercise: benchPress, order: 0, workout: workout),
            ScheduledWorkoutExercise(exercise: squat, order: 1, workout: workout)
        ]

        let model = WorkoutLogModel(source: .scheduled(workout))

        #expect(model.name == "Push Day")
        #expect(model.entries.map(\.exercise) == [benchPress, squat])
        #expect(model.entries.allSatisfy { $0.sets.count == 1 })
        #expect(model.entries.allSatisfy { $0.sets.first?.weightKg == 0 && $0.sets.first?.reps == 0 })

        workout.name = "Renamed"
        #expect(model.name == "Push Day")
    }

    @Test func initWithCustomSourceStartsWithNoEntries() {
        let model = WorkoutLogModel(source: .custom)

        #expect(model.name == nil)
        #expect(model.entries.isEmpty)
    }

    @Test func addExerciseAppendsToEndOfEntriesWithOneEmptySet() {
        let model = WorkoutLogModel(source: .custom)

        model.addExercise(benchPress)
        model.addExercise(squat)

        #expect(model.entries.map(\.exercise) == [benchPress, squat])
        #expect(model.entries.map(\.order) == [0, 1])
        #expect(model.entries.allSatisfy { $0.sets.count == 1 })
    }

    @Test func containedExercisesReflectsCurrentEntries() {
        let model = WorkoutLogModel(source: .custom)
        #expect(model.containedExercises.isEmpty)

        model.addExercise(benchPress)
        model.addExercise(squat)

        #expect(model.containedExercises == Set([benchPress, squat]))
    }

    @Test func toggleSkipFlipsIsSkippedOnThatEntryOnly() {
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.addExercise(squat)

        model.toggleSkip(model.entries[0])

        #expect(model.entries[0].isSkipped == true)
        #expect(model.entries[1].isSkipped == false)

        model.toggleSkip(model.entries[0])

        #expect(model.entries[0].isSkipped == false)
    }

    @Test func addSetAppendsAndRenumbersOnRemoval() {
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        let entry = model.entries[0]

        model.addSet(to: entry)
        model.addSet(to: entry)

        #expect(entry.sets.map(\.order) == [0, 1, 2])

        model.removeSet(entry.sets[1], from: entry)

        #expect(entry.sets.map(\.order) == [0, 1])
    }

    @Test func addSetInheritsWeightAndRepsFromThePreviousSet() {
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        let entry = model.entries[0]
        entry.sets[0].weightKg = 60
        entry.sets[0].reps = 8

        model.addSet(to: entry)

        #expect(entry.sets[1].weightKg == 60)
        #expect(entry.sets[1].reps == 8)
    }

    @Test func blocksGroupsContiguousSharedSupersetIDsInheritedFromTheSchedule() {
        let supersetID = UUID()
        let workout = ScheduledWorkout(dayOfWeek: .monday, name: "Push Day")
        workout.exercises = [
            ScheduledWorkoutExercise(exercise: benchPress, order: 0, supersetID: supersetID, workout: workout),
            ScheduledWorkoutExercise(exercise: squat, order: 1, supersetID: supersetID, workout: workout),
            ScheduledWorkoutExercise(exercise: deadlift, order: 2, workout: workout)
        ]

        let model = WorkoutLogModel(source: .scheduled(workout))

        #expect(model.blocks.count == 2)
        guard case let .superset(id, exercises) = model.blocks[0] else {
            Issue.record("Expected the first block to be a superset")
            return
        }
        #expect(id == supersetID)
        #expect(exercises.map(\.exercise) == [benchPress, squat])
        guard case let .exercise(standalone) = model.blocks[1] else {
            Issue.record("Expected the second block to be a standalone exercise")
            return
        }
        #expect(standalone.exercise == deadlift)
    }

    @Test func addingASetToOneSupersetMemberDoesNotAffectItsSiblings() {
        let supersetID = UUID()
        let workout = ScheduledWorkout(dayOfWeek: .monday, name: "Push Day")
        workout.exercises = [
            ScheduledWorkoutExercise(exercise: benchPress, order: 0, supersetID: supersetID, workout: workout),
            ScheduledWorkoutExercise(exercise: squat, order: 1, supersetID: supersetID, workout: workout)
        ]
        let model = WorkoutLogModel(source: .scheduled(workout))

        model.addSet(to: model.entries[0])

        #expect(model.entries[0].sets.count == 2)
        #expect(model.entries[1].sets.count == 1)
    }

    @Test func groupingTwoSelectedExercisesAssignsASharedSupersetIDAndMakesThemContiguous() {
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.addExercise(squat)
        model.addExercise(deadlift)

        model.beginGrouping()
        model.toggleSelection(model.blocks[0])
        model.toggleSelection(model.blocks[2])
        model.confirmGrouping()

        #expect(model.isSelectingForSuperset == false)
        #expect(model.blocks.count == 2)
        guard case let .superset(_, exercises) = model.blocks[0] else {
            Issue.record("Expected the first block to be a superset")
            return
        }
        #expect(exercises.map(\.exercise) == [benchPress, deadlift])
        guard case let .exercise(standalone) = model.blocks[1] else {
            Issue.record("Expected the second block to be a standalone exercise")
            return
        }
        #expect(standalone.exercise == squat)
    }

    @Test func ungroupingASupersetClearsSupersetIDOnItsMembers() {
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.addExercise(squat)
        model.beginGrouping()
        model.toggleSelection(model.blocks[0])
        model.toggleSelection(model.blocks[1])
        model.confirmGrouping()
        let supersetBlock = model.blocks[0]

        model.ungroup(supersetBlock)

        #expect(model.blocks.count == 2)
        #expect(model.entries.allSatisfy { $0.supersetID == nil })
    }

    @Test func canSaveIsFalseWhenEntriesIsEmpty() {
        let model = WorkoutLogModel(source: .custom)
        #expect(model.canSave == false)
    }

    @Test func canSaveIsTrueOnceAtLeastOneExerciseIsAdded() {
        let model = WorkoutLogModel(source: .custom)

        model.addExercise(benchPress)

        #expect(model.canSave == true)
    }

    @Test func saveInsertsTheFullWorkoutLogExerciseSetGraph() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)
        model.entries[0].sets[0].weightKg = 60
        model.entries[0].sets[0].reps = 5

        try model.save(context: context)

        let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.count == 1)
        #expect(logs.first?.exercises.count == 1)
        #expect(logs.first?.exercises.first?.exercise.name == "Bench Press")
        #expect(logs.first?.exercises.first?.sets.count == 1)
        #expect(logs.first?.exercises.first?.sets.first?.weightKg == 60)
        #expect(logs.first?.exercises.first?.sets.first?.reps == 5)
    }

    @Test func saveOnCustomSourceStoresANilName() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = WorkoutLogModel(source: .custom)
        model.addExercise(benchPress)

        try model.save(context: context)

        let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.first?.name == nil)
    }

    @Test func initCapturesTheGivenStartedAtAndSaveCapturesTheGivenFinishedAt() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let startedAt = Date(timeIntervalSince1970: 1000)
        let finishedAt = Date(timeIntervalSince1970: 2000)
        let model = WorkoutLogModel(source: .custom, startedAt: startedAt)
        model.addExercise(benchPress)

        #expect(model.startedAt == startedAt)

        try model.save(context: context, finishedAt: finishedAt)

        let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
        #expect(logs.first?.startedAt == startedAt)
        #expect(logs.first?.finishedAt == finishedAt)
    }
}
