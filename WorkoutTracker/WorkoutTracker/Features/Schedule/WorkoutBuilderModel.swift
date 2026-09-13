//
//  WorkoutBuilderModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class WorkoutBuilderModel {
    /// One row in the builder: either a standalone exercise or a superset of two or more exercises
    /// that share a `supersetID` and sit contiguously in `entries`.
    enum Block: Identifiable {
        case exercise(ScheduledWorkoutExercise)
        case superset(id: UUID, exercises: [ScheduledWorkoutExercise])

        var id: UUID {
            switch self {
            case let .exercise(entry): entry.id
            case let .superset(id, _): id
            }
        }
    }

    private static let logger = Logger(subsystem: "com.workouttracker", category: "WorkoutBuilderModel")

    let day: DayOfWeek
    var name: String
    var entries: [ScheduledWorkoutExercise]
    var isSelectingForSuperset = false
    var selectedBlockIDs: [UUID] = []

    private let existingWorkout: ScheduledWorkout?

    /// Saving an empty workout isn't allowed — the developer must use Cancel instead, per plan review.
    var canSave: Bool {
        !entries.isEmpty
    }

    var canConfirmGrouping: Bool {
        selectedBlockIDs.count >= 2
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

    var containedExercises: Set<Exercise> {
        Set(entries.map(\.exercise))
    }

    init(day: DayOfWeek, workout: ScheduledWorkout?) {
        self.day = day
        existingWorkout = workout
        name = workout?.name ?? ""
        entries = (workout?.exercises ?? []).sorted { $0.order < $1.order }
    }

    func addExercise(_ exercise: Exercise) {
        entries.append(ScheduledWorkoutExercise(exercise: exercise, order: entries.count))
    }

    func removeExercise(_ entry: ScheduledWorkoutExercise) {
        let removedSupersetID = entry.supersetID
        entries.removeAll { $0.id == entry.id }

        // A superset with only one member left no longer means anything as a group.
        if let removedSupersetID {
            let remainingMembers = entries.filter { $0.supersetID == removedSupersetID }
            if remainingMembers.count == 1 {
                remainingMembers[0].supersetID = nil
            }
        }

        renumberOrder()
    }

    /// Removes a whole block: one exercise for a standalone block, every member for a superset.
    func removeBlock(_ block: Block) {
        switch block {
        case let .exercise(entry):
            removeExercise(entry)
        case let .superset(_, exercises):
            let idsToRemove = Set(exercises.map(\.id))
            entries.removeAll { idsToRemove.contains($0.id) }
            renumberOrder()
        }
    }

    func removeAll() {
        entries.removeAll()
    }

    func moveBlock(fromOffsets source: IndexSet, toOffset destination: Int) {
        let reordered = Self.moving(blocks, fromOffsets: source, toOffset: destination)
        entries = flatten(reordered)
        renumberOrder()
    }

    /// Reorders the members of one superset in place, without touching any other block's position.
    func moveExercise(within supersetID: UUID, fromOffsets source: IndexSet, toOffset destination: Int) {
        var members = entries.filter { $0.supersetID == supersetID }.sorted { $0.order < $1.order }
        let orderSlots = members.map(\.order)
        members = Self.moving(members, fromOffsets: source, toOffset: destination)
        for (member, order) in zip(members, orderSlots) {
            member.order = order
        }
    }

    private static func moving<T>(_ items: [T], fromOffsets source: IndexSet, toOffset destination: Int) -> [T] {
        let moved = source.map { items[$0] }
        var remaining = items
        for index in source.sorted(by: >) {
            remaining.remove(at: index)
        }
        let adjustedDestination = destination - source.filter { $0 < destination }.count
        remaining.insert(contentsOf: moved, at: adjustedDestination)
        return remaining
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
    /// in the order they were selected, moved together to the position of the earliest selected block.
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

    func save(context: ModelContext) throws {
        guard canSave else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? nil : trimmedName

        let matchedWorkout = try existingWorkout ?? context.fetch(FetchDescriptor<ScheduledWorkout>())
            .first(where: { $0.dayOfWeek == day })

        let workout: ScheduledWorkout
        if let matchedWorkout {
            workout = matchedWorkout
            workout.name = resolvedName

            let currentIDs = Set(entries.map(\.id))
            for orphan in workout.exercises where !currentIDs.contains(orphan.id) {
                context.delete(orphan)
            }
        } else {
            workout = ScheduledWorkout(dayOfWeek: day, name: resolvedName)
            context.insert(workout)
        }

        for entry in entries where entry.modelContext == nil {
            context.insert(entry)
        }
        workout.exercises = entries

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save scheduled workout: \(error)")
            throw error
        }
    }

    private func renumberOrder() {
        for (index, entry) in entries.enumerated() {
            entry.order = index
        }
    }

    private func flatten(_ blocks: [Block]) -> [ScheduledWorkoutExercise] {
        blocks.flatMap { block -> [ScheduledWorkoutExercise] in
            switch block {
            case let .exercise(entry): [entry]
            case let .superset(_, exercises): exercises
            }
        }
    }
}
