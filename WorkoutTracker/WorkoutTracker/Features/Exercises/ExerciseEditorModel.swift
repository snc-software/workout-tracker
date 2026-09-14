//
//  ExerciseEditorModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class ExerciseEditorModel {
    enum MuscleSelectionGroup: Identifiable {
        case primary
        case secondary

        var id: Self {
            self
        }
    }

    enum WgerSearchState: Equatable {
        case idle
        case searching
        case loaded([WgerExerciseMatch])
        case empty
        case failed
    }

    /// A query shorter than this never reaches the network — avoids firing a request on every keystroke
    /// of a still-being-typed search term.
    private static let minimumWgerSearchLength = 2

    private static let logger = Logger(subsystem: "com.workouttracker", category: "ExerciseEditorModel")

    var name: String
    var category: ExerciseCategory?
    var primaryMuscles: Set<Muscle>
    var secondaryMuscles: Set<Muscle>
    private(set) var wgerSearchState = WgerSearchState.idle

    private let existingExercise: Exercise?
    private let wgerClient: any WgerExerciseSearching

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(exercise: Exercise?, wgerClient: any WgerExerciseSearching = WgerClient()) {
        existingExercise = exercise
        name = exercise?.name ?? ""
        category = exercise?.category
        primaryMuscles = Set(exercise?.primaryMuscles ?? [])
        secondaryMuscles = Set(exercise?.secondaryMuscles ?? [])
        self.wgerClient = wgerClient
    }

    func toggle(_ muscle: Muscle, in group: MuscleSelectionGroup) {
        switch group {
        case .primary:
            secondaryMuscles.remove(muscle)
            if !primaryMuscles.insert(muscle).inserted {
                primaryMuscles.remove(muscle)
            }
        case .secondary:
            primaryMuscles.remove(muscle)
            if !secondaryMuscles.insert(muscle).inserted {
                secondaryMuscles.remove(muscle)
            }
        }
    }

    /// Searches wger by name. A trimmed query under `minimumWgerSearchLength` resets to `.idle` without
    /// calling the network.
    func searchWger(matching query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= Self.minimumWgerSearchLength else {
            wgerSearchState = .idle
            return
        }

        wgerSearchState = .searching
        do {
            let dtos = try await wgerClient.searchExercises(matching: trimmedQuery)
            let matches = dtos.map(WgerExerciseMatch.init(dto:))
            wgerSearchState = matches.isEmpty ? .empty : .loaded(matches)
        } catch {
            Self.logger.error("Wger search failed: \(error)")
            wgerSearchState = .failed
        }
    }

    /// Pre-populates the editor from a selected wger match, replacing whatever name/category/muscles were
    /// already entered. A match's muscle region with no corresponding `Muscle` in `allMuscles`, or a
    /// category name with no corresponding `ExerciseCategory` in `allCategories`, is silently skipped, same
    /// as an exercise with no muscles/category picked yet.
    func applyWgerMatch(_ match: WgerExerciseMatch, allMuscles: [Muscle], allCategories: [ExerciseCategory]) {
        name = match.name
        category = allCategories.first(where: { $0.name == match.categoryName })
        primaryMuscles = Set(match.primaryMuscleNames.compactMap { regionName in
            allMuscles.first(where: { $0.name == regionName })
        })
        secondaryMuscles = Set(match.secondaryMuscleNames.compactMap { regionName in
            allMuscles.first(where: { $0.name == regionName })
        })
    }

    func save(context: ModelContext) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existingExercise {
            existingExercise.name = trimmedName
            existingExercise.category = category
            existingExercise.primaryMuscles = Array(primaryMuscles)
            existingExercise.secondaryMuscles = Array(secondaryMuscles)
        } else {
            let exercise = Exercise(
                name: trimmedName,
                category: category,
                primaryMuscles: Array(primaryMuscles),
                secondaryMuscles: Array(secondaryMuscles)
            )
            context.insert(exercise)
        }

        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save exercise: \(error)")
            throw error
        }
    }
}
