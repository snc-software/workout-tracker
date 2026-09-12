//
//  ExerciseEditorModelTests.swift
//  WorkoutTrackerTests
//

import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct ExerciseEditorModelTests {
    private let chest = Muscle(name: "chest", displayName: "Chest")
    private let triceps = Muscle(name: "triceps", displayName: "Triceps")

    @Test(arguments: ["", "   ", "\n"])
    func canSaveIsFalseForEmptyOrWhitespaceOnlyName(name: String) {
        let model = ExerciseEditorModel(exercise: nil)
        model.name = name

        #expect(model.canSave == false)
    }

    @Test func canSaveIsTrueOnceNonEmptyNameIsSet() {
        let model = ExerciseEditorModel(exercise: nil)
        model.name = "Barbell Bench Press"

        #expect(model.canSave == true)
    }

    @Test func togglingAddsToThePrimaryGroup() {
        let model = ExerciseEditorModel(exercise: nil)

        model.toggle(chest, in: .primary)

        #expect(model.primaryMuscles == [chest])
        #expect(model.secondaryMuscles.isEmpty)
    }

    @Test func togglingAddsToTheSecondaryGroup() {
        let model = ExerciseEditorModel(exercise: nil)

        model.toggle(chest, in: .secondary)

        #expect(model.secondaryMuscles == [chest])
        #expect(model.primaryMuscles.isEmpty)
    }

    @Test func togglingTheSameGroupTwiceRemovesTheMuscle() {
        let model = ExerciseEditorModel(exercise: nil)

        model.toggle(chest, in: .primary)
        model.toggle(chest, in: .primary)

        #expect(model.primaryMuscles.isEmpty)
    }

    @Test func togglingAMuscleSelectedInTheOtherGroupMovesIt() {
        let model = ExerciseEditorModel(exercise: nil)

        model.toggle(chest, in: .secondary)
        model.toggle(chest, in: .primary)

        #expect(model.primaryMuscles == [chest])
        #expect(model.secondaryMuscles.isEmpty)
    }

    @Test func initWithExistingExercisePrePopulatesFields() {
        let exercise = Exercise(name: "Barbell Bench Press", primaryMuscles: [chest], secondaryMuscles: [triceps])

        let model = ExerciseEditorModel(exercise: exercise)

        #expect(model.name == "Barbell Bench Press")
        #expect(model.primaryMuscles == [chest])
        #expect(model.secondaryMuscles == [triceps])
    }

    @Test func initWithNoExerciseStartsEmpty() {
        let model = ExerciseEditorModel(exercise: nil)

        #expect(model.name.isEmpty)
        #expect(model.primaryMuscles.isEmpty)
        #expect(model.secondaryMuscles.isEmpty)
    }

    @Test func saveOnNewModelInsertsANewExercise() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = ExerciseEditorModel(exercise: nil)
        model.name = "Barbell Bench Press"
        model.toggle(chest, in: .primary)
        model.toggle(triceps, in: .secondary)

        try model.save(context: context)

        let inserted = try context.fetch(FetchDescriptor<Exercise>())
        #expect(inserted.count == 1)
        #expect(inserted.first?.name == "Barbell Bench Press")
        #expect(inserted.first?.primaryMuscles.map(\.name) == ["chest"])
        #expect(inserted.first?.secondaryMuscles.map(\.name) == ["triceps"])
    }

    @Test func saveOnModelInitializedFromExistingExerciseUpdatesItInPlace() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let exercise = Exercise(name: "Bench Press")
        context.insert(exercise)
        try context.save()

        let model = ExerciseEditorModel(exercise: exercise)
        model.name = "Barbell Bench Press"
        model.toggle(chest, in: .primary)

        try model.save(context: context)

        let all = try context.fetch(FetchDescriptor<Exercise>())
        #expect(all.count == 1)
        #expect(all.first?.name == "Barbell Bench Press")
        #expect(all.first?.primaryMuscles.map(\.name) == ["chest"])
    }
}
