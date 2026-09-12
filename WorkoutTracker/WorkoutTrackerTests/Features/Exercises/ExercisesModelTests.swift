//
//  ExercisesModelTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct ExercisesModelTests {
    private let backCategory = ExerciseCategory(name: "Back")
    private let chestCategory = ExerciseCategory(name: "Chest")

    private var exercises: [Exercise] {
        [
            Exercise(name: "Barbell Deadlift", category: backCategory),
            Exercise(name: "Dumbbell Flat Bench", category: chestCategory),
            Exercise(name: "Barbell Flat Bench Press", category: chestCategory)
        ]
    }

    @Test func emptySearchTextReturnsAllExercisesInOrder() {
        let model = ExercisesModel()

        #expect(model.filteredExercises(from: exercises).map(\.name) == exercises.map(\.name))
    }

    @Test(arguments: ["bench", "BENCH", "Bench"])
    func matchingSubstringIsCaseInsensitive(term: String) {
        let model = ExercisesModel()
        model.searchText = term

        let result = model.filteredExercises(from: exercises).map(\.name)

        #expect(result == ["Dumbbell Flat Bench", "Barbell Flat Bench Press"])
    }

    @Test func noMatchReturnsEmptyResult() {
        let model = ExercisesModel()
        model.searchText = "Squat"

        #expect(model.filteredExercises(from: exercises).isEmpty)
    }

    @Test func selectingACategoryFiltersToThatCategoryOnly() {
        let model = ExercisesModel()
        model.selectedCategory = chestCategory

        let result = model.filteredExercises(from: exercises).map(\.name)

        #expect(result == ["Dumbbell Flat Bench", "Barbell Flat Bench Press"])
    }

    @Test func categoryAndSearchTextCombineToNarrowFurther() {
        let model = ExercisesModel()
        model.selectedCategory = chestCategory
        model.searchText = "Press"

        let result = model.filteredExercises(from: exercises).map(\.name)

        #expect(result == ["Barbell Flat Bench Press"])
    }

    @Test func noSelectedCategoryReturnsAllExercises() {
        let model = ExercisesModel()
        model.selectedCategory = nil

        #expect(model.filteredExercises(from: exercises).count == exercises.count)
    }
}
