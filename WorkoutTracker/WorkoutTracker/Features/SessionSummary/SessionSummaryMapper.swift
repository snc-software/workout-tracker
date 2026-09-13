//
//  SessionSummaryMapper.swift
//  WorkoutTracker
//
//  Mapping between WorkoutLog (persistence) and SessionSummary (domain).
//

import Foundation

extension SessionSummary {
    /// Persistence → domain. Reads `Exercise.personalRecord` to detect a new PR but never mutates it —
    /// applying a detected PR to the store is a deliberate follow-up step owned by `SessionSummaryModel`.
    init(workoutLog: WorkoutLog) {
        let activeEntries = workoutLog.exercises.filter { !$0.isSkipped }.sorted { $0.order < $1.order }

        var totalReps = 0
        var totalVolumeKg = 0.0
        var breakdowns: [ExerciseBreakdown] = []
        var newRecords: [NewPersonalRecord] = []
        var primaryMuscles: Set<Muscle> = []
        var secondaryMuscles: Set<Muscle> = []

        for entry in activeEntries {
            let sets = entry.sets.sorted { $0.order < $1.order }
            let entryReps = sets.reduce(0) { $0 + $1.reps }
            let entryVolumeKg = sets.reduce(0.0) { $0 + $1.weightKg * Double($1.reps) }
            let maxWeightKg = sets.map(\.weightKg).max() ?? 0

            totalReps += entryReps
            totalVolumeKg += entryVolumeKg

            breakdowns.append(
                ExerciseBreakdown(
                    exercise: entry.exercise,
                    setCount: sets.count,
                    totalReps: entryReps,
                    totalVolumeKg: entryVolumeKg,
                    sets: sets.map { SetDetail(order: $0.order, weightKg: $0.weightKg, reps: $0.reps) }
                )
            )

            let existingRecordWeightKg = entry.exercise.personalRecord?.weightKg
            let beatsExistingRecord = existingRecordWeightKg.map { maxWeightKg > $0 } ?? true
            if maxWeightKg > 0, beatsExistingRecord {
                newRecords.append(
                    NewPersonalRecord(
                        exercise: entry.exercise,
                        previousWeightKg: existingRecordWeightKg,
                        weightKg: maxWeightKg
                    )
                )
            }

            primaryMuscles.formUnion(entry.exercise.primaryMuscles)
            secondaryMuscles.formUnion(entry.exercise.secondaryMuscles)
        }

        // A muscle that's primary for one exercise and secondary for another reads as primary on the map.
        secondaryMuscles.subtract(primaryMuscles)

        name = workoutLog.name
        startedAt = workoutLog.startedAt
        finishedAt = workoutLog.finishedAt ?? workoutLog.startedAt
        self.totalReps = totalReps
        self.totalVolumeKg = totalVolumeKg
        exerciseBreakdowns = breakdowns
        newPersonalRecords = newRecords
        self.primaryMuscles = Array(primaryMuscles)
        self.secondaryMuscles = Array(secondaryMuscles)
    }
}
