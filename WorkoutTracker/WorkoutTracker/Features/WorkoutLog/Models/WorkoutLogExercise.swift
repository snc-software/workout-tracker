//
//  WorkoutLogExercise.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

/// One exercise logged within a `WorkoutLog`. `supersetID` seeds from the source
/// `ScheduledWorkoutExercise` at load time, and can also be assigned mid-log via
/// `WorkoutLogModel.confirmGrouping()`; either way it drives display grouping (see `WorkoutLogModel.blocks`).
@Model
final class WorkoutLogExercise {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var order: Int
    var supersetID: UUID?
    var isSkipped: Bool
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetLog.workoutLogExercise)
    var sets: [WorkoutSetLog]
    var workoutLog: WorkoutLog?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        order: Int,
        supersetID: UUID? = nil,
        isSkipped: Bool = false,
        sets: [WorkoutSetLog] = [],
        workoutLog: WorkoutLog? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.supersetID = supersetID
        self.isSkipped = isSkipped
        self.sets = sets
        self.workoutLog = workoutLog
    }
}
