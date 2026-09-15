//
//  WorkoutLogModel+PersonalRecords.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

extension WorkoutLogModel {
    /// For each non-skipped entry whose heaviest set beats the exercise's current `PersonalRecord` (or it
    /// doesn't have one yet), stamps the achieved weight onto the entry and updates/inserts the record,
    /// dated to this workout's finish time. Runs once, here, so "was this a PR" is a persisted fact rather
    /// than something re-derived later against `Exercise.personalRecord`, which moves on after this call.
    func applyPersonalRecords(log: WorkoutLog, finishedAt: Date, context: ModelContext) {
        for entry in entries where !entry.isSkipped {
            let maxWeightKg = entry.sets.map(\.weightKg).max() ?? 0
            guard maxWeightKg > 0 else { continue }

            let existingWeightKg = entry.exercise.personalRecord?.weightKg
            guard existingWeightKg.map({ maxWeightKg > $0 }) ?? true else { continue }

            entry.personalRecordWeightKg = maxWeightKg
            if let existingRecord = entry.exercise.personalRecord {
                existingRecord.weightKg = maxWeightKg
                existingRecord.achievedAt = finishedAt
                existingRecord.achievedInWorkout = log
            } else {
                context.insert(
                    PersonalRecord(
                        exercise: entry.exercise,
                        weightKg: maxWeightKg,
                        achievedAt: finishedAt,
                        achievedInWorkout: log
                    )
                )
            }
        }
    }

    /// Recalculates `PersonalRecord`s for an edited log. For an exercise this log doesn't currently hold
    /// the record for, the existing "does this beat the current best" comparison is still correct and
    /// reused as-is. For an exercise this log **does** currently hold the record for, the edit (up or
    /// down) might no longer be the true historical best, so this re-derives it against every other
    /// `WorkoutLogExercise` for that exercise — transferring the record to whichever one now legitimately
    /// holds it, or deleting it if nothing qualifies any more.
    func recalculatePersonalRecords(log: WorkoutLog, finishedAt: Date, context: ModelContext) throws {
        for entry in entries {
            try recalculatePersonalRecord(for: entry, log: log, finishedAt: finishedAt, context: context)
        }
    }

    /// Bundles the fields every private recalculation helper below needs, so passing them along stays
    /// within this file's 5-parameter limit as the call chain grows.
    private struct RecalculationContext {
        let log: WorkoutLog
        let finishedAt: Date
        let modelContext: ModelContext
    }

    private func recalculatePersonalRecord(
        for entry: WorkoutLogExercise,
        log: WorkoutLog,
        finishedAt: Date,
        context: ModelContext
    ) throws {
        let recalculation = RecalculationContext(log: log, finishedAt: finishedAt, modelContext: context)
        let exercise = entry.exercise
        let candidateWeightKg = entry.isSkipped ? 0 : (entry.sets.map(\.weightKg).max() ?? 0)

        guard let record = exercise.personalRecord, record.achievedInWorkout === log else {
            applyBeatsCheck(entry: entry, candidateWeightKg: candidateWeightKg, recalculation: recalculation)
            return
        }

        try reassignRecordCurrentlyHeldByThisLog(
            entry: entry,
            record: record,
            candidateWeightKg: candidateWeightKg,
            recalculation: recalculation
        )
    }

    /// `entry.exercise` doesn't currently hold its record with `recalculation.log` — reuse the plain "does
    /// this beat the current best" comparison unchanged.
    private func applyBeatsCheck(
        entry: WorkoutLogExercise,
        candidateWeightKg: Double,
        recalculation: RecalculationContext
    ) {
        let exercise = entry.exercise
        guard candidateWeightKg > 0 else {
            entry.personalRecordWeightKg = nil
            return
        }
        let currentBestWeightKg = exercise.personalRecord?.weightKg
        guard currentBestWeightKg.map({ candidateWeightKg > $0 }) ?? true else {
            entry.personalRecordWeightKg = nil
            return
        }

        entry.personalRecordWeightKg = candidateWeightKg
        if let existingRecord = exercise.personalRecord {
            existingRecord.weightKg = candidateWeightKg
            existingRecord.achievedAt = recalculation.finishedAt
            existingRecord.achievedInWorkout = recalculation.log
        } else {
            recalculation.modelContext.insert(
                PersonalRecord(
                    exercise: exercise,
                    weightKg: candidateWeightKg,
                    achievedAt: recalculation.finishedAt,
                    achievedInWorkout: recalculation.log
                )
            )
        }
    }

    /// `recalculation.log` currently holds `entry.exercise`'s record — recalculate against every other
    /// entry for it so editing this session (up or down) can't leave a stale weight or an orphaned record.
    private func reassignRecordCurrentlyHeldByThisLog(
        entry: WorkoutLogExercise,
        record: PersonalRecord,
        candidateWeightKg: Double,
        recalculation: RecalculationContext
    ) throws {
        let log = recalculation.log
        let exerciseID = entry.exercise.id
        let descriptor = FetchDescriptor<WorkoutLogExercise>(predicate: #Predicate { $0.exercise.id == exerciseID })
        let otherEntries = try recalculation.modelContext.fetch(descriptor)
            .filter { $0.workoutLog !== log && !$0.isSkipped }

        let bestOther = otherEntries
            .compactMap { other -> (WorkoutLogExercise, Double)? in
                guard let weight = other.sets.map(\.weightKg).max(), weight > 0 else { return nil }
                return (other, weight)
            }
            .max { $0.1 < $1.1 }

        if candidateWeightKg > 0, candidateWeightKg >= (bestOther?.1 ?? 0) {
            entry.personalRecordWeightKg = candidateWeightKg
            record.weightKg = candidateWeightKg
            record.achievedAt = recalculation.finishedAt
            record.achievedInWorkout = log
        } else {
            entry.personalRecordWeightKg = nil
            if let (otherEntry, otherWeight) = bestOther, let otherLog = otherEntry.workoutLog {
                otherEntry.personalRecordWeightKg = otherWeight
                record.weightKg = otherWeight
                record.achievedAt = otherLog.finishedAt ?? otherLog.startedAt
                record.achievedInWorkout = otherLog
            } else {
                recalculation.modelContext.delete(record)
            }
        }
    }
}
