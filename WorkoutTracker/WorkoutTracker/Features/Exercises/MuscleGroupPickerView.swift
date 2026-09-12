//
//  MuscleGroupPickerView.swift
//  WorkoutTracker
//

import SwiftUI

/// Sheet content for adding/removing muscles in one selection group. Deals only in our own
/// `Muscle` type — `MuscleMapPicker` has already resolved any tap back from the third-party
/// library before this view ever sees it.
struct MuscleGroupPickerView: View {
    @Environment(\.dismiss) private var dismiss

    let group: ExerciseEditorModel.MuscleSelectionGroup
    let model: ExerciseEditorModel
    let allMuscles: [Muscle]

    var body: some View {
        NavigationStack {
            MuscleMapPicker(
                allMuscles: allMuscles,
                primaryMuscles: Array(model.primaryMuscles),
                secondaryMuscles: Array(model.secondaryMuscles),
                onMuscleTapped: { muscle in
                    model.toggle(muscle, in: group)
                }
            )
            .padding()
            .navigationTitle(titleKey)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("exercises.editor.picker.done").font(Typography.body)
                    }
                }
            }
        }
    }

    private var titleKey: LocalizedStringKey {
        switch group {
        case .primary: return "exercises.editor.picker.primary.title"
        case .secondary: return "exercises.editor.picker.secondary.title"
        }
    }
}
