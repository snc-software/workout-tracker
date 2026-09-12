//
//  ExerciseSeederTests.swift
//  WorkoutTrackerTests
//

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
        #expect(try context.fetchCount(FetchDescriptor<Muscle>()) == 15)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 18)
    }

    @Test func seedingTwiceDoesNotDuplicateRows() throws {
        ExerciseSeeder.seedIfNeeded(context: context)
        ExerciseSeeder.seedIfNeeded(context: context)

        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 18)
    }
}
