//
//  SessionSummaryModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class SessionSummaryModel: Identifiable {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "SessionSummaryModel")

    let id = UUID()
    let summary: SessionSummary

    init(workoutLog: WorkoutLog) {
        summary = SessionSummary(workoutLog: workoutLog)
    }

    /// Persists each PR surfaced by `summary.newPersonalRecords`: updates the exercise's existing
    /// `PersonalRecord` in place, or inserts one when it doesn't have one yet.
    func applyNewPersonalRecords(context: ModelContext) throws {
        guard !summary.newPersonalRecords.isEmpty else { return }

        for newRecord in summary.newPersonalRecords {
            if let existingRecord = newRecord.exercise.personalRecord {
                existingRecord.weightKg = newRecord.weightKg
            } else {
                context.insert(PersonalRecord(exercise: newRecord.exercise, weightKg: newRecord.weightKg))
            }
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to persist new personal records: \(error)")
            throw error
        }
    }
}
