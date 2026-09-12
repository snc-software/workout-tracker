//
//  ExerciseMapperTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

struct ExerciseMapperTests {
    @Test func categoryMapsNameFromSeedDTO() {
        let dto = ExerciseCategorySeedDTO(id: "back", name: "Back")

        let category = ExerciseCategory(dto: dto)

        #expect(category.name == "Back")
    }

    @Test func muscleMapsAllFieldsFromSeedDTO() {
        let dto = MuscleSeedDTO(id: "latissimus-dorsi", name: "Latissimus dorsi", displayName: "Lats", isFront: false)

        let muscle = Muscle(dto: dto)

        #expect(muscle.name == "Latissimus dorsi")
        #expect(muscle.displayName == "Lats")
        #expect(muscle.isFront == false)
    }

    @Test func exerciseWiresResolvedRelationships() {
        let dto = ExerciseSeedDTO(
            name: "Barbell Deadlift",
            category: "back",
            primaryMuscles: ["latissimus-dorsi"],
            secondaryMuscles: ["gluteus-maximus"]
        )
        let category = ExerciseCategory(name: "Back")
        let lats = Muscle(name: "Latissimus dorsi", displayName: "Lats", isFront: false)
        let glutes = Muscle(name: "Gluteus maximus", displayName: "Glutes", isFront: false)

        let exercise = Exercise(dto: dto, category: category, primaryMuscles: [lats], secondaryMuscles: [glutes])

        #expect(exercise.name == "Barbell Deadlift")
        #expect(exercise.category === category)
        #expect(exercise.primaryMuscles == [lats])
        #expect(exercise.secondaryMuscles == [glutes])
    }

    @Test func exerciseDefaultsToNoMusclesWhenNoneResolved() {
        let dto = ExerciseSeedDTO(name: "Land mine Rotation", category: "abs", primaryMuscles: [], secondaryMuscles: [])

        let exercise = Exercise(dto: dto, category: nil, primaryMuscles: [], secondaryMuscles: [])

        #expect(exercise.category == nil)
        #expect(exercise.primaryMuscles.isEmpty)
        #expect(exercise.secondaryMuscles.isEmpty)
    }
}
