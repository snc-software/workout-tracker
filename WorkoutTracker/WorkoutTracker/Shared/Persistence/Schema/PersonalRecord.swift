//
//  PersonalRecord.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class PersonalRecord {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var weightKg: Double
    var achievedAt = Date.now
    /// The workout this record was achieved in, when it was set by beating a previous best during a
    /// logged session. `nil` for a manually created/edited record.
    var achievedInWorkout: WorkoutLog?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        weightKg: Double,
        achievedAt: Date = .now,
        achievedInWorkout: WorkoutLog? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.weightKg = weightKg
        self.achievedAt = achievedAt
        self.achievedInWorkout = achievedInWorkout
    }
}
