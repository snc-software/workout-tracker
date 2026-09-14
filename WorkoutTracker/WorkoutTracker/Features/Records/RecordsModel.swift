//
//  RecordsModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class RecordsModel {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "RecordsModel")

    func sortedRecords(from records: [PersonalRecord]) -> [PersonalRecord] {
        records.sorted { $0.exercise.name.localizedStandardCompare($1.exercise.name) == .orderedAscending }
    }

    func deleteRecord(_ record: PersonalRecord, context: ModelContext) throws {
        context.delete(record)
        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to delete personal record: \(error)")
            throw error
        }
    }
}
