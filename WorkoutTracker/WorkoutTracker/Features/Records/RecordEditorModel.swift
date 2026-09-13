//
//  RecordEditorModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class RecordEditorModel {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "RecordEditorModel")

    let exercise: Exercise
    var weightKg: Double

    private let existingRecord: PersonalRecord?

    var isEditing: Bool {
        existingRecord != nil
    }

    var canSave: Bool {
        weightKg > 0
    }

    init(exercise: Exercise, record: PersonalRecord? = nil) {
        self.exercise = exercise
        existingRecord = record
        weightKg = record?.weightKg ?? 0
    }

    func save(context: ModelContext) throws {
        if let existingRecord {
            existingRecord.weightKg = weightKg
            existingRecord.achievedAt = Date()
        } else {
            let record = PersonalRecord(exercise: exercise, weightKg: weightKg)
            context.insert(record)
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save personal record: \(error)")
            throw error
        }
    }

    func removeRecord(context: ModelContext) throws {
        guard let existingRecord else { return }
        context.delete(existingRecord)

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to remove personal record: \(error)")
            throw error
        }
    }
}
