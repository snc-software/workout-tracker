//
//  ExerciseSeeder.swift
//  WorkoutTracker
//
//  One-time population of the bundled wger-derived exercise library (see
//  Resources/SeedData/exercise-seed.json) into SwiftData. Runs synchronously on the main actor at app
//  launch — a fixed, one-time ~40-row seed, not the ongoing sync/bulk-import case
//  persistence-standards.md's @ModelActor rule targets.
//

import Foundation
import os
import SwiftData

enum ExerciseSeeder {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "ExerciseSeeder")

    static func seedIfNeeded(context: ModelContext) {
        let alreadySeeded = (try? context.fetchCount(FetchDescriptor<Exercise>())) ?? 0
        guard alreadySeeded == 0 else { return }

        guard let url = Bundle.main.url(forResource: "exercise-seed", withExtension: "json") else {
            preconditionFailure("Missing bundled resource: exercise-seed.json")
        }

        let file: ExerciseSeedFile
        do {
            let data = try Data(contentsOf: url)
            file = try JSONDecoder().decode(ExerciseSeedFile.self, from: data)
        } catch {
            preconditionFailure("Malformed bundled resource exercise-seed.json: \(error)")
        }

        var categoriesByID: [String: ExerciseCategory] = [:]
        for dto in file.categories {
            let category = ExerciseCategory(dto: dto)
            context.insert(category)
            categoriesByID[dto.id] = category
        }

        var musclesByID: [String: Muscle] = [:]
        for dto in file.muscles {
            let muscle = Muscle(dto: dto)
            context.insert(muscle)
            musclesByID[dto.id] = muscle
        }

        for dto in file.exercises {
            let exercise = Exercise(
                dto: dto,
                category: categoriesByID[dto.category],
                primaryMuscles: dto.primaryMuscles.compactMap { musclesByID[$0] },
                secondaryMuscles: dto.secondaryMuscles.compactMap { musclesByID[$0] }
            )
            context.insert(exercise)
        }

        do {
            try context.save()
        } catch {
            logger.error("Failed to save seeded exercise library: \(error)")
        }
    }
}
