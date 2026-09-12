//
//  Muscle.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class Muscle {
    @Attribute(.unique) var id: UUID
    var name: String
    var displayName: String
    var isFront: Bool

    init(id: UUID = UUID(), name: String, displayName: String, isFront: Bool) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.isFront = isFront
    }
}
