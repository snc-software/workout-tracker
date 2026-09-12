//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Scott Crowther on 12/09/2026.
//

import SwiftData
import SwiftUI

@main
struct WorkoutTrackerApp: App {
    private let modelContainer: ModelContainer

    init() {
        Typography.configureNavigationBarAppearance()

        let container = PersistenceController.makeContainer()
        ExerciseSeeder.seedIfNeeded(context: container.mainContext)
        modelContainer = container
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
