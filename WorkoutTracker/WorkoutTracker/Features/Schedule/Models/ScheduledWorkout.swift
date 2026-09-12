//
//  ScheduledWorkout.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class ScheduledWorkout {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) private var dayOfWeekRawValue: Int
    var name: String?
    @Relationship(deleteRule: .cascade, inverse: \ScheduledWorkoutExercise.workout)
    var exercises: [ScheduledWorkoutExercise]

    var dayOfWeek: DayOfWeek {
        get { DayOfWeek(rawValue: dayOfWeekRawValue) ?? .sunday }
        set { dayOfWeekRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        dayOfWeek: DayOfWeek,
        name: String? = nil,
        exercises: [ScheduledWorkoutExercise] = []
    ) {
        self.id = id
        dayOfWeekRawValue = dayOfWeek.rawValue
        self.name = name
        self.exercises = exercises
    }
}
