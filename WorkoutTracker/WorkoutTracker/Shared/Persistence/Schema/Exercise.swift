//
//  Exercise.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var category: ExerciseCategory?
    @Relationship(inverse: \Muscle.exercisesAsPrimary) var primaryMuscles: [Muscle]
    @Relationship(inverse: \Muscle.exercisesAsSecondary) var secondaryMuscles: [Muscle]

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory? = nil,
        primaryMuscles: [Muscle] = [],
        secondaryMuscles: [Muscle] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
    }
}
