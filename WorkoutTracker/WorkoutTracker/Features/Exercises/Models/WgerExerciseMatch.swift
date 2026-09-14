//
//  WgerExerciseMatch.swift
//  WorkoutTracker
//

import Foundation

/// One wger search result, already resolved onto our own `Muscle` catalog. `primaryMuscleNames` and
/// `secondaryMuscleNames` are `Muscle.name` region values (see ExerciseMapper.swift), ready to be looked
/// up against `allMuscles`.
struct WgerExerciseMatch: Identifiable, Equatable {
    let id: Int
    let name: String
    let categoryName: String
    let primaryMuscleNames: [String]
    let secondaryMuscleNames: [String]
}
