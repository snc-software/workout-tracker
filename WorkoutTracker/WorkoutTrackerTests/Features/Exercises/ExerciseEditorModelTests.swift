//
//  ExerciseEditorModelTests.swift
//  WorkoutTrackerTests
//

import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct ExerciseEditorModelTests {
    private struct FakeWgerClient: WgerExerciseSearching {
        let result: Result<[WgerExerciseInfoDTO], Error>

        func searchExercises(matching query: String) async throws -> [WgerExerciseInfoDTO] {
            try result.get()
        }
    }

    private struct SearchFailed: Error {}

    private let chest = Muscle(name: "chest", displayName: "Chest")
    private let triceps = Muscle(name: "triceps", displayName: "Triceps")
    private let chestCategory = ExerciseCategory(name: "Chest")

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
        let exercise = Exercise(
            name: "Barbell Bench Press",
            category: chestCategory,
            primaryMuscles: [chest],
            secondaryMuscles: [triceps]
        )

        let model = ExerciseEditorModel(exercise: exercise)

        #expect(model.name == "Barbell Bench Press")
        #expect(model.category === chestCategory)
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
        model.category = chestCategory
        model.toggle(chest, in: .primary)
        model.toggle(triceps, in: .secondary)

        try model.save(context: context)

        let inserted = try context.fetch(FetchDescriptor<Exercise>())
        #expect(inserted.count == 1)
        #expect(inserted.first?.name == "Barbell Bench Press")
        #expect(inserted.first?.category === chestCategory)
        #expect(inserted.first?.primaryMuscles.map(\.name) == ["chest"])
        #expect(inserted.first?.secondaryMuscles.map(\.name) == ["triceps"])
    }

    @Test func searchWgerSetsLoadedStateWithMappedMatchesOnSuccess() async {
        let dto = WgerExerciseInfoDTO(
            id: 73,
            category: WgerCategoryDTO(name: "Chest"),
            muscles: [WgerMuscleDTO(name: "Pectoralis major")],
            musclesSecondary: [],
            translations: [WgerTranslationDTO(language: 2, name: "Bench Press")]
        )
        let model = ExerciseEditorModel(exercise: nil, wgerClient: FakeWgerClient(result: .success([dto])))

        await model.searchWger(matching: "bench")

        #expect(model.wgerSearchState == .loaded([WgerExerciseMatch(dto: dto)]))
    }

    @Test func searchWgerSetsEmptyStateWhenNoMatchesReturn() async {
        let model = ExerciseEditorModel(exercise: nil, wgerClient: FakeWgerClient(result: .success([])))

        await model.searchWger(matching: "zzzzzz")

        #expect(model.wgerSearchState == .empty)
    }

    @Test func searchWgerSetsFailedStateWhenTheClientThrows() async {
        let model = ExerciseEditorModel(exercise: nil, wgerClient: FakeWgerClient(result: .failure(SearchFailed())))

        await model.searchWger(matching: "bench")

        #expect(model.wgerSearchState == .failed)
    }

    @Test func searchWgerResetsToIdleForAQueryUnderTwoCharactersWithoutCallingTheClient() async {
        // Throwing proves the client is never called for a too-short query.
        let model = ExerciseEditorModel(exercise: nil, wgerClient: FakeWgerClient(result: .failure(SearchFailed())))

        await model.searchWger(matching: "b")

        #expect(model.wgerSearchState == .idle)
    }

    @Test func applyWgerMatchSetsNameCategoryAndResolvesMusclesFromAllMuscles() {
        let match = WgerExerciseMatch(
            id: 73,
            name: "Bench Press",
            categoryName: "Chest",
            primaryMuscleNames: ["chest"],
            secondaryMuscleNames: ["triceps"]
        )
        let model = ExerciseEditorModel(exercise: nil)

        model.applyWgerMatch(match, allMuscles: [chest, triceps], allCategories: [chestCategory])

        #expect(model.name == "Bench Press")
        #expect(model.category === chestCategory)
        #expect(model.primaryMuscles == [chest])
        #expect(model.secondaryMuscles == [triceps])
    }

    @Test func applyWgerMatchSkipsARegionNameNotPresentInAllMuscles() {
        let match = WgerExerciseMatch(
            id: 1,
            name: "Some Exercise",
            categoryName: "Chest",
            primaryMuscleNames: ["chest"],
            secondaryMuscleNames: []
        )
        let model = ExerciseEditorModel(exercise: nil)

        model.applyWgerMatch(match, allMuscles: [triceps], allCategories: [chestCategory])

        #expect(model.name == "Some Exercise")
        #expect(model.primaryMuscles.isEmpty)
    }

    @Test func applyWgerMatchSkipsACategoryNameNotPresentInAllCategories() {
        let match = WgerExerciseMatch(
            id: 1,
            name: "Some Exercise",
            categoryName: "Cardio",
            primaryMuscleNames: [],
            secondaryMuscleNames: []
        )
        let model = ExerciseEditorModel(exercise: nil)

        model.applyWgerMatch(match, allMuscles: [], allCategories: [chestCategory])

        #expect(model.category == nil)
    }

    @Test func saveOnModelInitializedFromExistingExerciseUpdatesItInPlace() throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let exercise = Exercise(name: "Bench Press")
        context.insert(exercise)
        try context.save()

        let model = ExerciseEditorModel(exercise: exercise)
        model.name = "Barbell Bench Press"
        model.category = chestCategory
        model.toggle(chest, in: .primary)

        try model.save(context: context)

        let all = try context.fetch(FetchDescriptor<Exercise>())
        #expect(all.count == 1)
        #expect(all.first?.name == "Barbell Bench Press")
        #expect(all.first?.category === chestCategory)
        #expect(all.first?.primaryMuscles.map(\.name) == ["chest"])
    }
}
