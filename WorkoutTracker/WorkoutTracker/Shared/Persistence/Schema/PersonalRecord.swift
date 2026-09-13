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

    init(id: UUID = UUID(), exercise: Exercise, weightKg: Double) {
        self.id = id
        self.exercise = exercise
        self.weightKg = weightKg
    }
}
