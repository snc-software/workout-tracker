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
        self.init(name: dto.name, displayName: dto.displayName)
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

extension WgerExerciseMatch {
    private static let englishLanguageID = 2

    /// wger's Latin muscle name → our own `Muscle.name` (`MuscleMap` SDK region rawValue). Not keyed by
    /// wger's numeric id or `name_en` (blank for several entries). `Brachialis` folds into `biceps`, and
    /// both `Gastrocnemius` and `Soleus` fold into `calves`, since our catalog has no separate regions
    /// for them.
    private static let regionByWgerMuscleName: [String: String] = [
        "Anterior deltoid": "deltoids",
        "Biceps brachii": "biceps",
        "Biceps femoris": "hamstring",
        "Brachialis": "biceps",
        "Gastrocnemius": "calves",
        "Gluteus maximus": "gluteal",
        "Latissimus dorsi": "upper-back",
        "Obliquus externus abdominis": "obliques",
        "Pectoralis major": "chest",
        "Quadriceps femoris": "quadriceps",
        "Rectus abdominis": "abs",
        "Serratus anterior": "serratus",
        "Soleus": "calves",
        "Trapezius": "trapezius",
        "Triceps brachii": "triceps"
    ]

    /// Maps a list of wger muscles onto our region names, dropping any wger muscle with no entry in
    /// `regionByWgerMuscleName` and de-duplicating two wger muscles that map to the same region.
    private static func uniqueRegions(from muscles: [WgerMuscleDTO]) -> [String] {
        var seenRegions = Set<String>()
        var regions: [String] = []
        for muscle in muscles {
            guard let region = regionByWgerMuscleName[muscle.name], seenRegions.insert(region).inserted else {
                continue
            }
            regions.append(region)
        }
        return regions
    }

    /// Wire → domain. When the same region (e.g. `calves`) appears in both `muscles` and
    /// `musclesSecondary` — wger treats Gastrocnemius/Soleus as distinct muscles, our catalog doesn't —
    /// the primary occurrence wins and the secondary one is dropped.
    init(dto: WgerExerciseInfoDTO) {
        let name = dto.translations.first(where: { $0.language == Self.englishLanguageID })?.name ?? ""
        let primaryMuscleNames = Self.uniqueRegions(from: dto.muscles)
        let secondaryMuscleNames = Self.uniqueRegions(from: dto.musclesSecondary)
            .filter { !primaryMuscleNames.contains($0) }

        self.init(
            id: dto.id,
            name: name,
            categoryName: dto.category.name,
            primaryMuscleNames: primaryMuscleNames,
            secondaryMuscleNames: secondaryMuscleNames
        )
    }
}
