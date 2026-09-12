//
//  ExercisesModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class ExercisesModel {
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
}
