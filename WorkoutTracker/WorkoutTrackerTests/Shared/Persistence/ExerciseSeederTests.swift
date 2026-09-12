//
//  ExerciseSeederTests.swift
//  WorkoutTrackerTests
//

import MuscleMap
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct ExerciseSeederTests {
    // ModelContext does not retain its ModelContainer, so the container must be held here for the
    // duration of the test or the context is left pointing at a deallocated store.
    private let container = PersistenceController.makeContainer(inMemory: true)
    private var context: ModelContext {
        container.mainContext
    }

    @Test func seedingAnEmptyStoreInsertsTheBundledLibrary() throws {
        ExerciseSeeder.seedIfNeeded(context: context)

        #expect(try context.fetchCount(FetchDescriptor<ExerciseCategory>()) == 8)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutTracker.Muscle>()) == 13)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 18)
    }

    @Test func seedingTwiceDoesNotDuplicateRows() throws {
        ExerciseSeeder.seedIfNeeded(context: context)
        ExerciseSeeder.seedIfNeeded(context: context)

        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 18)
    }

    /// `Muscle.name` is only meaningful if it matches a real `MuscleMap.Muscle` region rawValue —
    /// there's no compiler-checked mapping table to catch a typo here anymore.
    @Test func everySeededMuscleNameIsAValidMuscleMapRegion() throws {
        ExerciseSeeder.seedIfNeeded(context: context)

        let muscles = try context.fetch(FetchDescriptor<WorkoutTracker.Muscle>())

        for muscle in muscles {
            let name = muscle.name
            #expect(MuscleMap.Muscle(rawValue: name) != nil, "\(name) is not a MuscleMap region")
        }
    }

    @Test func everySeededExerciseHasAtLeastOnePrimaryMuscle() throws {
        ExerciseSeeder.seedIfNeeded(context: context)

        let exercises = try context.fetch(FetchDescriptor<Exercise>())

        for exercise in exercises {
            #expect(!exercise.primaryMuscles.isEmpty, "\(exercise.name) has no primary muscles")
        }
    }
}
