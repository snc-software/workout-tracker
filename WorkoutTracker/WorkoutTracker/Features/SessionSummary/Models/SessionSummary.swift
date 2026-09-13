//
//  SessionSummary.swift
//  WorkoutTracker
//

import Foundation

/// The computed result of a finished `WorkoutLog`: totals, a per-exercise breakdown, any personal
/// records hit this session, and the muscles worked, aggregated across every non-skipped exercise.
struct SessionSummary {
    struct SetDetail: Identifiable {
        let order: Int
        let weightKg: Double
        let reps: Int

        var id: Int {
            order
        }
    }

    struct ExerciseBreakdown: Identifiable {
        let exercise: Exercise
        let setCount: Int
        let totalReps: Int
        let totalVolumeKg: Double
        let sets: [SetDetail]

        var id: UUID {
            exercise.id
        }
    }

    struct NewPersonalRecord: Identifiable {
        let exercise: Exercise
        let previousWeightKg: Double?
        let weightKg: Double

        var id: UUID {
            exercise.id
        }
    }

    let name: String?
    let startedAt: Date
    let finishedAt: Date
    let totalReps: Int
    let totalVolumeKg: Double
    let exerciseBreakdowns: [ExerciseBreakdown]
    let newPersonalRecords: [NewPersonalRecord]
    let primaryMuscles: [Muscle]
    let secondaryMuscles: [Muscle]
}
