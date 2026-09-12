//
//  MuscleMapPicker.swift
//  WorkoutTracker
//

import MuscleMap
import SwiftUI

/// Facade over the third-party MuscleMap SDK: renders front + back body views highlighting the
/// given primary/secondary muscles, and — when `onMuscleGroupTapped` is set — resolves taps back
/// to our own `Muscle` type. Callers never see `MuscleMap.Muscle` or `import MuscleMap`.
struct MuscleMapPicker: View {
    let allMuscles: [Muscle]
    let primaryMuscles: [Muscle]
    let secondaryMuscles: [Muscle]
    var onMuscleGroupTapped: (([Muscle]) -> Void)?

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

        if let onMuscleGroupTapped {
            view = view.onMuscleSelected { region, _ in
                onMuscleGroupTapped(Muscle.muscles(forRegion: region, in: allMuscles))
            }
        }

        return view
    }

    private var primaryRegions: [MuscleMap.Muscle] {
        primaryMuscles.compactMap(\.muscleMapRegion)
    }

    private var secondaryRegions: [MuscleMap.Muscle] {
        secondaryMuscles.compactMap(\.muscleMapRegion)
    }
}
