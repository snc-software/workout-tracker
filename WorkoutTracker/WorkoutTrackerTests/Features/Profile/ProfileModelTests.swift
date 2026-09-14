//
//  ProfileModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct ProfileModelTests {
    private let container = PersistenceController.makeContainer(inMemory: true)
    private var context: ModelContext {
        container.mainContext
    }

    @Test func updatingNameTrimsWhitespaceAndPersists() {
        let profile = UserProfile()
        context.insert(profile)
        let model = ProfileModel()

        model.updateName("  Scott  ", on: profile, context: context)

        #expect(profile.name == "Scott")
    }

    @Test func updatingNameToBlankClearsIt() {
        let profile = UserProfile(name: "Scott")
        context.insert(profile)
        let model = ProfileModel()

        model.updateName("   ", on: profile, context: context)

        #expect(profile.name == "")
    }

    @Test func updatingMuscleMapGenderPersistsRawValue() {
        let profile = UserProfile()
        context.insert(profile)
        let model = ProfileModel()

        model.updateMuscleMapGender(.female, on: profile, context: context)

        #expect(profile.muscleMapGenderRawValue == "female")
    }

    @Test func updatingThemePersistsRawValue() {
        let profile = UserProfile()
        context.insert(profile)
        let model = ProfileModel()

        model.updateTheme(.dark, on: profile, context: context)

        #expect(profile.themeRawValue == "dark")
    }

    @Test func updatingAppIconCallsTheInjectedSetterAndPersistsOnSuccess() async {
        let profile = UserProfile()
        context.insert(profile)

        var requestedName: String?
        let model = ProfileModel { name in
            requestedName = name
        }

        await model.updateAppIcon(AppIconOption(id: "AppIcon-Dark", displayName: "Dark"), on: profile, context: context)

        #expect(requestedName == "AppIcon-Dark")
        #expect(profile.appIconName == "AppIcon-Dark")
    }

    @Test func updatingAppIconLeavesThePersistedValueUnchangedWhenTheSetterThrows() async {
        struct SetterError: Error {}

        let profile = UserProfile(appIconName: "AppIcon-Dark")
        context.insert(profile)
        let model = ProfileModel { _ in throw SetterError() }

        await model.updateAppIcon(AppIconOption.defaultOption, on: profile, context: context)

        #expect(profile.appIconName == "AppIcon-Dark")
    }
}
