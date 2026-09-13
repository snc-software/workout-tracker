//
//  PersonalRecord.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class PersonalRecord {
    @Attribute(.unique) var id: UUID
    var exercise: Exercise
    var weightKg: Double
    var achievedAt = Date.now

    init(id: UUID = UUID(), exercise: Exercise, weightKg: Double, achievedAt: Date = .now) {
        self.id = id
        self.exercise = exercise
        self.weightKg = weightKg
        self.achievedAt = achievedAt
    }
}
