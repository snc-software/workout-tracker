//
//  PersistenceController.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

enum PersistenceController {
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            Exercise.self,
            Muscle.self,
            ExerciseCategory.self,
            ScheduledWorkout.self,
            ScheduledWorkoutExercise.self,
            PersonalRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
