//
//  RecordEditorModelTests.swift
//  WorkoutTrackerTests
//

import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct RecordEditorModelTests {
    @Test(arguments: [0, -5])
    func canSaveIsFalseForZeroOrNegativeWeight(weight: Double) {
        let model = RecordEditorModel(exercise: Exercise(name: "Bench Press"))
        model.weightKg = weight

        #expect(model.canSave == false)
    }

    @Test func canSaveIsTrueForAPositiveWeight() {
        let model = RecordEditorModel(exercise: Exercise(name: "Bench Press"))
        model.weightKg = 82.5

        #expect(model.canSave == true)
    }

    @Test func initWithNoExistingRecordStartsAtZeroAndNotEditing() {
        let model = RecordEditorModel(exercise: Exercise(name: "Bench Press"))

        #expect(model.weightKg == 0)
        #expect(model.isEditing == false)
    }

    @Test func initWithExistingRecordPrePopulatesWeightAndIsEditing() {
        let exercise = Exercise(name: "Bench Press")
        let record = PersonalRecord(exercise: exercise, weightKg: 82.5)

        let model = RecordEditorModel(exercise: exercise, record: record)

        #expect(model.weightKg == 82.5)
        #expect(model.isEditing == true)
    }

    @Test func saveOnNewModelInsertsANewPersonalRecordForTheExercise() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let exercise = Exercise(name: "Bench Press")
        context.insert(exercise)
        try context.save()

        let model = RecordEditorModel(exercise: exercise)
        model.weightKg = 82.5

        try model.save(context: context)

        let inserted = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(inserted.count == 1)
        #expect(inserted.first?.exercise.name == "Bench Press")
        #expect(inserted.first?.weightKg == 82.5)
    }

    @Test func saveOnModelInitializedFromExistingRecordUpdatesItInPlace() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let exercise = Exercise(name: "Bench Press")
        let record = PersonalRecord(exercise: exercise, weightKg: 80)
        context.insert(exercise)
        context.insert(record)
        try context.save()

        let model = RecordEditorModel(exercise: exercise, record: record)
        model.weightKg = 85

        try model.save(context: context)

        let all = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(all.count == 1)
        #expect(all.first?.weightKg == 85)
    }

    @Test func removeRecordDeletesTheExistingRecord() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let exercise = Exercise(name: "Bench Press")
        let record = PersonalRecord(exercise: exercise, weightKg: 80)
        context.insert(exercise)
        context.insert(record)
        try context.save()

        let model = RecordEditorModel(exercise: exercise, record: record)
        try model.removeRecord(context: context)

        let all = try context.fetch(FetchDescriptor<PersonalRecord>())
        #expect(all.isEmpty)
    }
}
