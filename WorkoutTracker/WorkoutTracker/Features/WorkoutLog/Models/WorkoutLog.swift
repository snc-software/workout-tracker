//
//  WorkoutLog.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

/// A completed or in-progress logging session. Holds no live link back to the `ScheduledWorkout` it may
/// have been started from, so editing or deleting that schedule later never affects a saved log.
@Model
final class WorkoutLog {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var finishedAt: Date?
    var name: String?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutLogExercise.workoutLog)
    var exercises: [WorkoutLogExercise]

    init(
        id: UUID = UUID(),
        startedAt: Date,
        finishedAt: Date? = nil,
        name: String? = nil,
        exercises: [WorkoutLogExercise] = []
    ) {
        self.id = id
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.name = name
        self.exercises = exercises
    }
}
