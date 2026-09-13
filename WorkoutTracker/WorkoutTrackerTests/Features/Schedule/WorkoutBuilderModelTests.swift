//
//  WorkoutBuilderModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct WorkoutBuilderModelTests {
    private let benchPress = Exercise(name: "Bench Press")
    private let squat = Exercise(name: "Squat")
    private let deadlift = Exercise(name: "Deadlift")

    @Test func addExerciseAppendsToEndOfEntries() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)

        model.addExercise(benchPress)
        model.addExercise(squat)

        #expect(model.entries.map(\.exercise) == [benchPress, squat])
        #expect(model.entries.map(\.order) == [0, 1])
    }

    @Test func removeExerciseRemovesItAndClosesTheOrderGap() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.addExercise(benchPress)
        model.addExercise(squat)
        model.addExercise(deadlift)

        model.removeExercise(model.entries[1])

        #expect(model.entries.map(\.exercise) == [benchPress, deadlift])
        #expect(model.entries.map(\.order) == [0, 1])
    }

    @Test func removeAllClearsEntries() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.addExercise(benchPress)
        model.addExercise(squat)

        model.removeAll()

        #expect(model.entries.isEmpty)
    }

    @Test func movingABlockReordersEntriesAndRenumbersOrder() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.addExercise(benchPress)
        model.addExercise(squat)
        model.addExercise(deadlift)

        model.moveBlock(fromOffsets: IndexSet(integer: 0), toOffset: 3)

        #expect(model.entries.map(\.exercise) == [squat, deadlift, benchPress])
        #expect(model.entries.map(\.order) == [0, 1, 2])
    }

    @Test func movingAnExerciseWithinASupersetReordersOnlyItsMembers() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.addExercise(benchPress)
        model.addExercise(squat)
        model.addExercise(deadlift)
        let outsider = Exercise(name: "Row")
        model.addExercise(outsider)

        model.beginGrouping()
        model.toggleSelection(model.blocks[0])
        model.toggleSelection(model.blocks[1])
        model.toggleSelection(model.blocks[2])
        model.confirmGrouping()
        guard case let .superset(supersetID, _) = model.blocks[0] else {
            Issue.record("Expected the first block to be a superset")
            return
        }

        model.moveExercise(within: supersetID, fromOffsets: IndexSet(integer: 2), toOffset: 0)

        guard case let .superset(_, exercises) = model.blocks[0] else {
            Issue.record("Expected the first block to still be a superset")
            return
        }
        #expect(exercises.map(\.exercise) == [deadlift, benchPress, squat])
        #expect(model.blocks.count == 2)
        guard case let .exercise(standalone) = model.blocks[1] else {
            Issue.record("Expected the second block to remain the standalone exercise")
            return
        }
        #expect(standalone.exercise == outsider)
    }

    @Test func groupingTwoSelectedExercisesAssignsASharedSupersetIDAndMakesThemContiguous() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
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
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
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
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        #expect(model.canSave == false)

        model.addExercise(benchPress)
        model.removeAll()
        #expect(model.canSave == false)
    }

    @Test func canSaveIsTrueOnceAtLeastOneExerciseIsAdded() {
        let model = WorkoutBuilderModel(day: .monday, workout: nil)

        model.addExercise(benchPress)

        #expect(model.canSave == true)
    }

    @Test func saveOnNewModelInsertsAScheduledWorkoutForTheDay() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.name = "Push Day"
        model.addExercise(benchPress)
        model.addExercise(squat)

        try model.save(context: context)

        let inserted = try context.fetch(FetchDescriptor<ScheduledWorkout>())
        #expect(inserted.count == 1)
        #expect(inserted.first?.dayOfWeek == .monday)
        #expect(inserted.first?.name == "Push Day")
        #expect(
            inserted.first?.exercises.sorted(by: { $0.order < $1.order }).map(\.exercise.name)
                == ["Bench Press", "Squat"]
        )
    }

    @Test func saveOnModelInitializedFromExistingWorkoutUpdatesItInPlace() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let existing = ScheduledWorkout(dayOfWeek: .tuesday, name: "Leg Day")
        existing.exercises = [ScheduledWorkoutExercise(exercise: squat, order: 0, workout: existing)]
        context.insert(existing)
        try context.save()

        let model = WorkoutBuilderModel(day: .tuesday, workout: existing)
        model.removeExercise(model.entries[0])
        model.addExercise(deadlift)
        model.name = "Updated Leg Day"

        try model.save(context: context)

        let all = try context.fetch(FetchDescriptor<ScheduledWorkout>())
        #expect(all.count == 1)
        #expect(all.first?.name == "Updated Leg Day")
        #expect(all.first?.exercises.map(\.exercise.name) == ["Deadlift"])
    }

    @Test(arguments: ["", "   ", "\n"])
    func nameIsTrimmedAndNilWhenBlank(name: String) throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = WorkoutBuilderModel(day: .monday, workout: nil)
        model.name = name
        model.addExercise(benchPress)

        try model.save(context: context)

        let inserted = try context.fetch(FetchDescriptor<ScheduledWorkout>())
        #expect(inserted.first?.name == nil)
    }

    @Test func savingASecondWorkoutForTheSameDayReplacesRatherThanDuplicates() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))

        let first = WorkoutBuilderModel(day: .friday, workout: nil)
        first.addExercise(benchPress)
        try first.save(context: context)

        let second = WorkoutBuilderModel(day: .friday, workout: nil)
        second.addExercise(squat)
        try second.save(context: context)

        let all = try context.fetch(FetchDescriptor<ScheduledWorkout>())
        #expect(all.count == 1)
        #expect(all.first?.exercises.map(\.exercise.name) == ["Squat"])
    }
}
