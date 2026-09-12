//
//  Muscle.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

@Model
final class Muscle {
    @Attribute(.unique) var id: UUID
    /// A `MuscleMap.Muscle` region rawValue (e.g. `"chest"`, `"calves"`) — the catalog matches
    /// the SDK's regions 1:1, so no separate mapping layer is needed to highlight/resolve taps.
    var name: String
    var displayName: String

    // SwiftData can't disambiguate two to-many relationships from Exercise to the same
    // destination type without an explicit inverse each — without these, sharing a Muscle
    // row across many exercises silently drops some exercises' primary/secondary muscles.
    var exercisesAsPrimary: [Exercise] = []
    var exercisesAsSecondary: [Exercise] = []

    init(id: UUID = UUID(), name: String, displayName: String) {
        self.id = id
        self.name = name
        self.displayName = displayName
    }
}
