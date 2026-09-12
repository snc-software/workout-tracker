//
//  MuscleMapPicker.swift
//  WorkoutTracker
//

import MuscleMap
import SwiftUI

/// Facade over the third-party MuscleMap SDK: renders front + back body views highlighting the
/// given primary/secondary muscles, and — when `onMuscleTapped` is set — resolves taps back to
/// our own `Muscle` type. Callers never see `MuscleMap.Muscle` or `import MuscleMap`.
///
/// `Muscle.name` is a `MuscleMap.Muscle` region rawValue, so the catalog matches the SDK's
/// regions 1:1 and this is just an identity lookup, not a many-to-one mapping.
struct MuscleMapPicker: View {
    let allMuscles: [Muscle]
    let primaryMuscles: [Muscle]
    let secondaryMuscles: [Muscle]
    var onMuscleTapped: ((Muscle) -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            bodyView(side: .front)
            bodyView(side: .back)
        }
    }

    private func bodyView(side: BodySide) -> some View {
        var view = MuscleMap.BodyView(gender: .male, side: side)
            .highlight(primaryRegions, color: Color("primaryBrand"))
            .highlight(secondaryRegions, color: Color("accent"))

        if let onMuscleTapped {
            view = view.onMuscleSelected { region, _ in
                if let muscle = allMuscles.first(where: { $0.name == region.rawValue }) {
                    onMuscleTapped(muscle)
                }
            }
        }

        return view
    }

    private var primaryRegions: [MuscleMap.Muscle] {
        primaryMuscles.compactMap { MuscleMap.Muscle(rawValue: $0.name) }
    }

    private var secondaryRegions: [MuscleMap.Muscle] {
        secondaryMuscles.compactMap { MuscleMap.Muscle(rawValue: $0.name) }
    }
}
