//
//  WorkoutSetLog.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class WorkoutSetLog {
    @Attribute(.unique) var id: UUID
    var order: Int
    var weightKg: Double
    var reps: Int
    var workoutLogExercise: WorkoutLogExercise?

    init(
        id: UUID = UUID(),
        order: Int,
        weightKg: Double,
        reps: Int,
        workoutLogExercise: WorkoutLogExercise? = nil
    ) {
        self.id = id
        self.order = order
        self.weightKg = weightKg
        self.reps = reps
        self.workoutLogExercise = workoutLogExercise
    }
}
