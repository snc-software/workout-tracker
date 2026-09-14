//
//  HistoryModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class HistoryModel {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "HistoryModel")

    func completedWorkouts(from logs: [WorkoutLog]) -> [WorkoutLog] {
        logs
            .filter { $0.finishedAt != nil }
            .sorted { ($0.finishedAt ?? .distantPast) > ($1.finishedAt ?? .distantPast) }
    }

    func deleteWorkout(_ log: WorkoutLog, context: ModelContext) throws {
        context.delete(log)
        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to delete workout log: \(error)")
            throw error
        }
    }
}
