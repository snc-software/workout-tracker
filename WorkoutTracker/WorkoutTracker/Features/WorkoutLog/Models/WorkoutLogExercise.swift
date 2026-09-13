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
    /// The heaviest weight logged for this exercise in this session, set by
    /// `WorkoutLogModel.save(context:finishedAt:)` only when it was a new PB at the moment of saving — `nil`
    /// otherwise. Read directly by `SessionSummaryMapper`, so "was this a PR" is decided exactly once, at
    /// save time, rather than re-derived later against `Exercise.personalRecord`, which is live, mutable
    /// state that a later re-read (e.g. from History) would find already updated to match this very session.
    var personalRecordWeightKg: Double?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSetLog.workoutLogExercise)
    var sets: [WorkoutSetLog]
    var workoutLog: WorkoutLog?

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        order: Int,
        supersetID: UUID? = nil,
        isSkipped: Bool = false,
        personalRecordWeightKg: Double? = nil,
        sets: [WorkoutSetLog] = [],
        workoutLog: WorkoutLog? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.supersetID = supersetID
        self.isSkipped = isSkipped
        self.personalRecordWeightKg = personalRecordWeightKg
        self.sets = sets
        self.workoutLog = workoutLog
    }
}
