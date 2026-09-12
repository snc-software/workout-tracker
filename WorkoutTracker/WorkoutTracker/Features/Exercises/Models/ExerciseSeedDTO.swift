//
//  ExerciseSeedDTO.swift
//  WorkoutTracker
//
//  Codable shape of Resources/SeedData/exercise-seed.json, resolved from wger's public
//  exercise database (see research/*.json) against the app's own stable string ids.
//

import Foundation

struct ExerciseSeedFile: Codable {
    let categories: [ExerciseCategorySeedDTO]
    let muscles: [MuscleSeedDTO]
    let exercises: [ExerciseSeedDTO]
}

struct ExerciseCategorySeedDTO: Codable {
    let id: String
    let name: String
}

struct MuscleSeedDTO: Codable {
    let id: String
    let name: String
    let displayName: String
    let isFront: Bool
}

struct ExerciseSeedDTO: Codable {
    let name: String
    let category: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
}
