//
//  ScheduledWorkoutExercise.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

/// One exercise placed in a `ScheduledWorkout`. `order` is its position in the workout's flat,
/// ordered list; a shared non-nil `supersetID` across contiguous `order`s renders those entries
/// as one superset block (see `WorkoutBuilderModel.blocks`).
@Model
final class ScheduledWorkoutExercise {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var order: Int
    var supersetID: UUID?
    var workout: ScheduledWorkout?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        order: Int,
        supersetID: UUID? = nil,
        workout: ScheduledWorkout? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.supersetID = supersetID
        self.workout = workout
    }
}
