//
//  ExercisesModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class ExercisesModel {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "ExercisesModel")

    var searchText: String = ""
    var selectedCategory: ExerciseCategory?

    func filteredExercises(from exercises: [Exercise]) -> [Exercise] {
        var result = exercises
        if let selectedCategory {
            result = result.filter { $0.category == selectedCategory }
        }
        guard !searchText.isEmpty else { return result }
        return result.filter { $0.name.localizedStandardContains(searchText) }
    }

    func deleteExercise(_ exercise: Exercise, context: ModelContext) throws {
        context.delete(exercise)
        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to delete exercise: \(error)")
            throw error
        }
    }
}
