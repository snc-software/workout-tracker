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
    /// Mutable so a historical entry's `WorkoutLogView` can bind a `DatePicker` to it; a live session
    /// never mutates it after init.
    var startedAt: Date
    var entries: [WorkoutLogExercise]
    var isSelectingForSuperset = false
    var selectedBlockIDs: [UUID] = []

    /// Non-`nil` only when this model edits an already-saved log rather than starting a new session.
    /// `entries` then holds detached copies (same `id`s, no `modelContext`) of `existingLog`'s exercises
    /// and sets, not the live objects — every mutation during the edit (including `WorkoutSetRow`'s direct
    /// `@Bindable` bindings) touches only those copies, so cancelling is a true no-op regardless of
    /// SwiftData's autosave. `save(context:finishedAt:)` reconciles the copies back onto `existingLog` by
    /// `id` instead of inserting a new log.
    private let existingLog: WorkoutLog?

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
        existingLog = nil

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

    /// Edits an already-saved `log` in place. `entries` is built from detached copies of `log`'s
    /// exercises/sets (see `existingLog`) rather than the live objects, so nothing is written to `log`
    /// until `save(context:finishedAt:)` is called.
    init(editing log: WorkoutLog) {
        source = .custom
        name = log.name
        startedAt = log.startedAt
        existingLog = log
        entries = log.exercises.sorted { $0.order < $1.order }.map { entry in
            WorkoutLogExercise(
                id: entry.id,
                exercise: entry.exercise,
                order: entry.order,
                supersetID: entry.supersetID,
                isSkipped: entry.isSkipped,
                sets: entry.sets.sorted { $0.order < $1.order }.map { set in
                    WorkoutSetLog(id: set.id, order: set.order, weightKg: set.weightKg, reps: set.reps)
                }
            )
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
        let log = existingLog ?? WorkoutLog(startedAt: startedAt, finishedAt: finishedAt, name: name)
        guard canSave else { return log }

        if let existingLog {
            existingLog.startedAt = startedAt
            existingLog.finishedAt = finishedAt
            reconcile(log: existingLog, context: context)
            do {
                try recalculatePersonalRecords(log: existingLog, finishedAt: finishedAt, context: context)
            } catch {
                Self.logger.error("Failed to recalculate personal records: \(error)")
                throw error
            }
        } else {
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
            applyPersonalRecords(log: log, finishedAt: finishedAt, context: context)
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save workout log: \(error)")
            throw error
        }

        return log
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
