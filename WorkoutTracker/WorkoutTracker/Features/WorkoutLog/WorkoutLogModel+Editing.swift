//
//  WorkoutLogModel+Editing.swift
//  WorkoutTracker
//

import SwiftData

extension WorkoutLogModel {
    /// Matches the detached `entries`/`sets` built by `init(editing:)` onto `log`'s real, persisted graph
    /// by `id`: updates a matched exercise/set in place, inserts one with no persisted counterpart (added
    /// during this edit), and deletes a persisted set with no counterpart left in the draft (removed
    /// during this edit). Exercises are never deleted this way — the UI only ever adds or skips one, never
    /// removes it — so only sets need the removal side of this diff. Reassigns `entries` to the now-
    /// persisted objects so PR recalculation (and any further use of `entries` this save) operates on the
    /// real graph, not the discarded draft.
    func reconcile(log: WorkoutLog, context: ModelContext) {
        var persistedByID = Dictionary(uniqueKeysWithValues: log.exercises.map { ($0.id, $0) })
        var reconciledEntries: [WorkoutLogExercise] = []

        for draft in entries {
            if let persisted = persistedByID.removeValue(forKey: draft.id) {
                persisted.order = draft.order
                persisted.supersetID = draft.supersetID
                persisted.isSkipped = draft.isSkipped
                reconcileSets(persisted: persisted, draft: draft, context: context)
                reconciledEntries.append(persisted)
            } else {
                context.insert(draft)
                for set in draft.sets {
                    context.insert(set)
                }
                reconciledEntries.append(draft)
            }
        }

        log.exercises = reconciledEntries
        entries = reconciledEntries
    }

    private func reconcileSets(persisted: WorkoutLogExercise, draft: WorkoutLogExercise, context: ModelContext) {
        var persistedByID = Dictionary(uniqueKeysWithValues: persisted.sets.map { ($0.id, $0) })
        var reconciledSets: [WorkoutSetLog] = []

        for draftSet in draft.sets {
            if let persistedSet = persistedByID.removeValue(forKey: draftSet.id) {
                persistedSet.order = draftSet.order
                persistedSet.weightKg = draftSet.weightKg
                persistedSet.reps = draftSet.reps
                reconciledSets.append(persistedSet)
            } else {
                context.insert(draftSet)
                reconciledSets.append(draftSet)
            }
        }

        for removed in persistedByID.values {
            context.delete(removed)
        }

        persisted.sets = reconciledSets
    }
}
