//
//  ExerciseMapperTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct ExerciseMapperTests {
    @Test func categoryMapsNameFromSeedDTO() {
        let dto = ExerciseCategorySeedDTO(id: "back", name: "Back")

        let category = ExerciseCategory(dto: dto)

        #expect(category.name == "Back")
    }

    @Test func muscleMapsAllFieldsFromSeedDTO() {
        let dto = MuscleSeedDTO(id: "upper-back", name: "upper-back", displayName: "Lats")

        let muscle = Muscle(dto: dto)

        #expect(muscle.name == "upper-back")
        #expect(muscle.displayName == "Lats")
    }

    @Test func exerciseWiresResolvedRelationships() {
        let dto = ExerciseSeedDTO(
            name: "Barbell Deadlift",
            category: "back",
            primaryMuscles: ["latissimus-dorsi"],
            secondaryMuscles: ["gluteus-maximus"]
        )
        let category = ExerciseCategory(name: "Back")
        let lats = Muscle(name: "upper-back", displayName: "Lats")
        let glutes = Muscle(name: "gluteal", displayName: "Glutes")

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

    @Test func wgerExerciseMatchInitFromDTOMapsEnglishNameAndMuscles() {
        let dto = WgerExerciseInfoDTO(
            id: 73,
            category: WgerCategoryDTO(name: "Chest"),
            muscles: [WgerMuscleDTO(name: "Pectoralis major")],
            musclesSecondary: [WgerMuscleDTO(name: "Anterior deltoid"), WgerMuscleDTO(name: "Triceps brachii")],
            translations: [
                WgerTranslationDTO(language: 1, name: "Bankdrücken LH"),
                WgerTranslationDTO(language: 2, name: "Bench Press")
            ]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.id == 73)
        #expect(match.name == "Bench Press")
        #expect(match.primaryMuscleNames == ["chest"])
        #expect(match.secondaryMuscleNames == ["deltoids", "triceps"])
    }

    @Test func wgerExerciseMatchInitFromDTOMapsCategoryName() {
        let dto = WgerExerciseInfoDTO(
            id: 73,
            category: WgerCategoryDTO(name: "Chest"),
            muscles: [],
            musclesSecondary: [],
            translations: [WgerTranslationDTO(language: 2, name: "Bench Press")]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.categoryName == "Chest")
    }

    @Test func wgerExerciseMatchInitFromDTOFallsBackToEmptyNameWhenNoEnglishTranslation() {
        let dto = WgerExerciseInfoDTO(
            id: 1,
            category: WgerCategoryDTO(name: "Chest"),
            muscles: [],
            musclesSecondary: [],
            translations: [WgerTranslationDTO(language: 1, name: "Bankdrücken LH")]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.name.isEmpty)
    }

    @Test func wgerExerciseMatchInitFromDTOMapsBrachialisToBiceps() {
        let dto = WgerExerciseInfoDTO(
            id: 348,
            category: WgerCategoryDTO(name: "Arms"),
            muscles: [WgerMuscleDTO(name: "Brachialis")],
            musclesSecondary: [],
            translations: [WgerTranslationDTO(language: 2, name: "Hammer Curl")]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.primaryMuscleNames == ["biceps"])
    }

    @Test func wgerExerciseMatchInitFromDTODeduplicatesTwoWgerMusclesMappingToTheSameRegionWithinOneList() {
        let dto = WgerExerciseInfoDTO(
            id: 622,
            category: WgerCategoryDTO(name: "Calves"),
            muscles: [WgerMuscleDTO(name: "Gastrocnemius"), WgerMuscleDTO(name: "Soleus")],
            musclesSecondary: [],
            translations: [WgerTranslationDTO(language: 2, name: "Calf Raise")]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.primaryMuscleNames == ["calves"])
    }

    @Test func wgerExerciseMatchInitFromDTOPrefersPrimaryWhenTheSameRegionAppearsInBothLists() {
        let dto = WgerExerciseInfoDTO(
            id: 622,
            category: WgerCategoryDTO(name: "Calves"),
            muscles: [WgerMuscleDTO(name: "Gastrocnemius")],
            musclesSecondary: [WgerMuscleDTO(name: "Soleus")],
            translations: [WgerTranslationDTO(language: 2, name: "Calf Raise")]
        )

        let match = WgerExerciseMatch(dto: dto)

        #expect(match.primaryMuscleNames == ["calves"])
        #expect(match.secondaryMuscleNames.isEmpty)
    }
}
