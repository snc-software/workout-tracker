//
//  UserProfileSeederTests.swift
//  WorkoutTrackerTests
//

import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct UserProfileSeederTests {
    private let container = PersistenceController.makeContainer(inMemory: true)
    private var context: ModelContext {
        container.mainContext
    }

    @Test func seedingAnEmptyStoreInsertsOneDefaultRow() throws {
        UserProfileSeeder.seedIfNeeded(context: context)

        let profiles = try context.fetch(FetchDescriptor<UserProfile>())
        #expect(profiles.count == 1)
        #expect(profiles.first?.name == "")
        #expect(profiles.first?.theme == .system)
        #expect(profiles.first?.muscleMapGender == .male)
        #expect(profiles.first?.appIconName == nil)
    }

    @Test func seedingTwiceDoesNotDuplicateRows() throws {
        UserProfileSeeder.seedIfNeeded(context: context)
        UserProfileSeeder.seedIfNeeded(context: context)

        #expect(try context.fetchCount(FetchDescriptor<UserProfile>()) == 1)
    }
}
