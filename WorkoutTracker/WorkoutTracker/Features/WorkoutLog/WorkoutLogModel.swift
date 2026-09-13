//
//  WorkoutLogModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class WorkoutLogModel {
    /// What the logging session was started from.
    enum Source: Identifiable {
        case scheduled(ScheduledWorkout)
        case custom

        var id: String {
            switch self {
            case let .scheduled(workout): "scheduled-\(workout.id)"
            case .custom: "custom"
            }
        }
    }

    /// One row in the log: either a standalone exercise or a superset, whether inherited from the
    /// source schedule or grouped mid-log via `confirmGrouping()`.
    enum Block: Identifiable {
        case exercise(WorkoutLogExercise)
        case superset(id: UUID, exercises: [WorkoutLogExercise])

        var id: UUID {
            switch self {
            case let .exercise(entry): entry.id
            case let .superset(id, _): id
            }
        }
    }

    private static let logger = Logger(subsystem: "com.workouttracker", category: "WorkoutLogModel")

    let source: Source
    let name: String?
    let startedAt: Date
    var entries: [WorkoutLogExercise]
    var isSelectingForSuperset = false
    var selectedBlockIDs: [UUID] = []

    var canSave: Bool {
        !entries.isEmpty
    }

    var canConfirmGrouping: Bool {
        selectedBlockIDs.count >= 2
    }

    var containedExercises: Set<Exercise> {
        Set(entries.map(\.exercise))
    }

    var blocks: [Block] {
        var result: [Block] = []
        let sorted = entries.sorted { $0.order < $1.order }
        var index = 0
        while index < sorted.count {
            let entry = sorted[index]
            if let supersetID = entry.supersetID {
                var members = [entry]
                var next = index + 1
                while next < sorted.count, sorted[next].supersetID == supersetID {
                    members.append(sorted[next])
                    next += 1
                }
                result.append(.superset(id: supersetID, exercises: members))
                index = next
            } else {
                result.append(.exercise(entry))
                index += 1
            }
        }
        return result
    }

    init(source: Source, startedAt: Date = Date()) {
        self.source = source
        self.startedAt = startedAt

        switch source {
        case let .scheduled(workout):
            name = workout.displayTitle
            entries = workout.exercises.sorted { $0.order < $1.order }.map { scheduledExercise in
                WorkoutLogExercise(
                    exercise: scheduledExercise.exercise,
                    order: scheduledExercise.order,
                    supersetID: scheduledExercise.supersetID,
                    sets: [WorkoutSetLog(order: 0, weightKg: 0, reps: 0)]
                )
            }
        case .custom:
            name = nil
            entries = []
        }
    }

    func addExercise(_ exercise: Exercise) {
        entries.append(
            WorkoutLogExercise(
                exercise: exercise,
                order: entries.count,
                sets: [WorkoutSetLog(order: 0, weightKg: 0, reps: 0)]
            )
        )
    }

    func toggleSkip(_ entry: WorkoutLogExercise) {
        entry.isSkipped.toggle()
    }

    func addSet(to entry: WorkoutLogExercise) {
        let previous = entry.sets.max { $0.order < $1.order }
        entry.sets.append(
            WorkoutSetLog(order: entry.sets.count, weightKg: previous?.weightKg ?? 0, reps: previous?.reps ?? 0)
        )
    }

    func removeSet(_ set: WorkoutSetLog, from entry: WorkoutLogExercise) {
        entry.sets.removeAll { $0.id == set.id }
        for (index, remaining) in entry.sets.sorted(by: { $0.order < $1.order }).enumerated() {
            remaining.order = index
        }
    }

    func beginGrouping() {
        isSelectingForSuperset = true
        selectedBlockIDs = []
    }

    func cancelGrouping() {
        isSelectingForSuperset = false
        selectedBlockIDs = []
    }

    func toggleSelection(_ block: Block) {
        if let index = selectedBlockIDs.firstIndex(of: block.id) {
            selectedBlockIDs.remove(at: index)
        } else {
            selectedBlockIDs.append(block.id)
        }
    }

    /// Merges the selected blocks (standalone exercises and/or existing supersets) into one superset,
    /// moved together to the position of the earliest selected block.
    func confirmGrouping() {
        let selectedBlocks = selectedBlockIDs.compactMap { id in blocks.first { $0.id == id } }
        guard selectedBlocks.count >= 2 else {
            cancelGrouping()
            return
        }

        let supersetID = UUID()
        let selectedEntries = flatten(selectedBlocks)
        for entry in selectedEntries {
            entry.supersetID = supersetID
        }

        let selectedIDs = Set(selectedEntries.map(\.id))
        let insertionOrder = selectedEntries.map(\.order).min() ?? entries.count
        var remaining = entries.filter { !selectedIDs.contains($0.id) }
        let insertionIndex = remaining.firstIndex { $0.order > insertionOrder } ?? remaining.count
        remaining.insert(contentsOf: selectedEntries, at: insertionIndex)

        entries = remaining
        renumberOrder()
        cancelGrouping()
    }

    func ungroup(_ block: Block) {
        guard case let .superset(_, exercises) = block else { return }
        for entry in exercises {
            entry.supersetID = nil
        }
    }

    @discardableResult
    func save(context: ModelContext, finishedAt: Date = Date()) throws -> WorkoutLog {
        let log = WorkoutLog(startedAt: startedAt, finishedAt: finishedAt, name: name)
        guard canSave else { return log }

        context.insert(log)

        for entry in entries {
            if entry.modelContext == nil {
                context.insert(entry)
            }
            for set in entry.sets where set.modelContext == nil {
                context.insert(set)
            }
        }
        log.exercises = entries
        applyPersonalRecords(finishedAt: finishedAt, context: context)

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save workout log: \(error)")
            throw error
        }

        return log
    }

    /// For each non-skipped entry whose heaviest set beats the exercise's current `PersonalRecord` (or it
    /// doesn't have one yet), stamps the achieved weight onto the entry and updates/inserts the record,
    /// dated to this workout's finish time. Runs once, here, so "was this a PR" is a persisted fact rather
    /// than something re-derived later against `Exercise.personalRecord`, which moves on after this call.
    private func applyPersonalRecords(finishedAt: Date, context: ModelContext) {
        for entry in entries where !entry.isSkipped {
            let maxWeightKg = entry.sets.map(\.weightKg).max() ?? 0
            guard maxWeightKg > 0 else { continue }

            let existingWeightKg = entry.exercise.personalRecord?.weightKg
            guard existingWeightKg.map({ maxWeightKg > $0 }) ?? true else { continue }

            entry.personalRecordWeightKg = maxWeightKg
            if let existingRecord = entry.exercise.personalRecord {
                existingRecord.weightKg = maxWeightKg
                existingRecord.achievedAt = finishedAt
            } else {
                context.insert(PersonalRecord(exercise: entry.exercise, weightKg: maxWeightKg, achievedAt: finishedAt))
            }
        }
    }

    private func renumberOrder() {
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }
    }

    private func flatten(_ blocks: [Block]) -> [WorkoutLogExercise] {
        blocks.flatMap { block -> [WorkoutLogExercise] in
            switch block {
            case let .exercise(entry): [entry]
            case let .superset(_, exercises): exercises
            }
        }
    }
}
