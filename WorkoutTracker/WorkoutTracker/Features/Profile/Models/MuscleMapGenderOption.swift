//
//  MuscleMapGenderOption.swift
//  WorkoutTracker
//

import SwiftUI

/// Rawvalues intentionally match `MuscleMap.BodyGender`'s rawValues 1:1 (mirroring how `Muscle.name`
/// matches `MuscleMap.Muscle`'s rawValues) — `MuscleMapPicker` is the one place that SDK type is used.
enum MuscleMapGenderOption: String, CaseIterable, Codable, Sendable, Identifiable {
    case male
    case female

    var id: String {
        rawValue
    }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .male: "profile.muscleMapGender.male"
        case .female: "profile.muscleMapGender.female"
        }
    }
}
