//
//  ExerciseEditorModel.swift
//  WorkoutTracker
//

import Foundation
import SwiftData
import os

@Observable
final class ExerciseEditorModel {
    enum MuscleSelectionGroup: Identifiable {
        case primary
        case secondary

        var id: Self { self }
    }

    private static let logger = Logger(subsystem: "com.workouttracker", category: "ExerciseEditorModel")

    var name: String
    var primaryMuscles: Set<Muscle>
    var secondaryMuscles: Set<Muscle>

    private let existingExercise: Exercise?

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(exercise: Exercise?) {
        self.existingExercise = exercise
        self.name = exercise?.name ?? ""
        self.primaryMuscles = Set(exercise?.primaryMuscles ?? [])
        self.secondaryMuscles = Set(exercise?.secondaryMuscles ?? [])
    }

    func toggle(_ muscle: Muscle, in group: MuscleSelectionGroup) {
        switch group {
        case .primary:
            secondaryMuscles.remove(muscle)
            if !primaryMuscles.insert(muscle).inserted {
                primaryMuscles.remove(muscle)
            }
        case .secondary:
            primaryMuscles.remove(muscle)
            if !secondaryMuscles.insert(muscle).inserted {
                secondaryMuscles.remove(muscle)
            }
        }
    }

    func save(context: ModelContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingExercise {
            existingExercise.name = trimmedName
            existingExercise.primaryMuscles = Array(primaryMuscles)
            existingExercise.secondaryMuscles = Array(secondaryMuscles)
        } else {
            let exercise = Exercise(
                name: trimmedName,
                primaryMuscles: Array(primaryMuscles),
                secondaryMuscles: Array(secondaryMuscles)
            )
            context.insert(exercise)
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save exercise: \(error)")
            throw error
        }
    }
}
