//
//  ExerciseCategory.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class ExerciseCategory {
    @Attribute(.unique) var id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
