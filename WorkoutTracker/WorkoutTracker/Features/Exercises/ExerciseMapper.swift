//
//  ExerciseMapper.swift
//  WorkoutTracker
//
//  Mapping between the seed DTOs (ExerciseCategorySeedDTO, MuscleSeedDTO, ExerciseSeedDTO) and their
//  persistence (@Model) counterparts. The DTO's string id is only a lookup key for resolving
//  relationships (see ExerciseSeeder) — each @Model still gets its own generated UUID identity.
//

import Foundation

extension ExerciseCategory {
    /// Seed file → persistence.
    convenience init(dto: ExerciseCategorySeedDTO) {
        self.init(name: dto.name)
    }
}

extension Muscle {
    /// Seed file → persistence.
    convenience init(dto: MuscleSeedDTO) {
        self.init(name: dto.name, displayName: dto.displayName, isFront: dto.isFront)
    }
}

extension Exercise {
    /// Seed file → persistence, once the DTO's category/muscle id references have been resolved.
    convenience init(
        dto: ExerciseSeedDTO,
        category: ExerciseCategory?,
        primaryMuscles: [Muscle],
        secondaryMuscles: [Muscle]
    ) {
        self.init(
            name: dto.name,
            category: category,
            primaryMuscles: primaryMuscles,
            secondaryMuscles: secondaryMuscles
        )
    }
}
