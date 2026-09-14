//
//  WgerExerciseInfoDTO.swift
//  WorkoutTracker
//

import Foundation

/// Wire shape of `GET /api/v2/exerciseinfo/`.
nonisolated struct WgerSearchResponseDTO: Decodable, Sendable {
    let results: [WgerExerciseInfoDTO]
}

nonisolated struct WgerExerciseInfoDTO: Decodable, Sendable {
    let id: Int
    let category: WgerCategoryDTO
    let muscles: [WgerMuscleDTO]
    let musclesSecondary: [WgerMuscleDTO]
    let translations: [WgerTranslationDTO]

    private enum CodingKeys: String, CodingKey {
        case id, category, muscles
        case musclesSecondary = "muscles_secondary"
        case translations
    }
}

/// wger's category names ("Chest", "Back", ...) match `ExerciseCategory.name` in our own seed catalog
/// exactly (see research/exercise-category.json), so only `name` is decoded here and resolved by exact
/// match, the same as `ExerciseMapper.uniqueRegions(from:)` does for muscles.
nonisolated struct WgerCategoryDTO: Decodable, Sendable {
    let name: String
}

/// Only `name` is decoded — the wger→our-region mapping in `ExerciseMapper.swift` keys off wger's Latin
/// muscle name, not its numeric id or (inconsistently populated) `name_en`.
nonisolated struct WgerMuscleDTO: Decodable, Sendable {
    let name: String
}

nonisolated struct WgerTranslationDTO: Decodable, Sendable {
    let language: Int
    let name: String
}
