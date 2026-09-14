//
//  ExerciseEditorView.swift
//  WorkoutTracker
//

import Foundation
import Iconoir
import SwiftData
import SwiftUI

struct ExerciseEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Muscle.name) private var allMuscles: [Muscle]
    @Query(sort: \ExerciseCategory.name) private var categories: [ExerciseCategory]
    @Query private var profiles: [UserProfile]

    @State private var model: ExerciseEditorModel
    @State private var pickerGroup: ExerciseEditorModel.MuscleSelectionGroup?
    @State private var isWgerSearchPresented = false

    private let isEditing: Bool

    init(exercise: Exercise? = nil) {
        isEditing = exercise != nil
        _model = State(initialValue: ExerciseEditorModel(exercise: exercise))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $model.name)
                        .font(Typography.body)
                        .accessibilityLabel("exercises.editor.name.label")
                        .accessibilityIdentifier("exercises.editor.name.field")

                    if !isEditing {
                        Button {
                            isWgerSearchPresented = true
                        } label: {
                            Label {
                                Text("exercises.editor.wger.entry")
                                    .font(Typography.body)
                            } icon: {
                                Iconoir.globe.asImage
                            }
                        }
                        .accessibilityIdentifier("exercises.editor.wger.entry")
                    }
                } header: {
                    sectionHeader("exercises.editor.name.label")
                }

                Section {
                    Picker(selection: $model.category) {
                        Text("exercises.editor.category.none")
                            .tag(ExerciseCategory?.none)
                        ForEach(categories) { category in
                            Text(category.name)
                                .tag(ExerciseCategory?.some(category))
                        }
                    } label: {
                        Text("exercises.editor.category.label")
                            .font(Typography.body)
                    }
                    .accessibilityIdentifier("exercises.editor.category.picker")
                } header: {
                    sectionHeader("exercises.editor.category.label")
                }

                Section {
                    MuscleMapPicker(
                        allMuscles: allMuscles,
                        primaryMuscles: Array(model.primaryMuscles),
                        secondaryMuscles: Array(model.secondaryMuscles),
                        gender: profiles.first?.muscleMapGenderRawValue ?? MuscleMapGenderOption.male.rawValue,
                        onMuscleTapped: nil
                    )
                    .frame(height: 220)

                    HStack(spacing: 16) {
                        legendItem(color: Color("primaryBrand"), titleKey: "exercises.editor.legend.primary")
                        legendItem(color: Color("accent"), titleKey: "exercises.editor.legend.secondary")
                    }
                } header: {
                    sectionHeader("exercises.editor.muscles.title")
                }

                muscleGroupSection(
                    titleKey: "exercises.editor.primaryGroup.title",
                    muscles: model.primaryMuscles,
                    color: Color("primaryBrand"),
                    removeLabelKey: "exercises.editor.chip.remove.primary",
                    group: .primary
                )

                muscleGroupSection(
                    titleKey: "exercises.editor.secondaryGroup.title",
                    muscles: model.secondaryMuscles,
                    color: Color("accent"),
                    removeLabelKey: "exercises.editor.chip.remove.secondary",
                    group: .secondary
                )
            }
            .navigationTitle(isEditing ? "exercises.editor.edit.title" : "exercises.editor.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("exercises.editor.cancel")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text("exercises.editor.save").font(Typography.body)
                    }
                    .disabled(!model.canSave)
                    .accessibilityIdentifier("exercises.editor.save")
                }
            }
            .sheet(item: $pickerGroup) { group in
                MuscleGroupPickerView(group: group, model: model, allMuscles: allMuscles)
            }
            .sheet(isPresented: $isWgerSearchPresented) {
                WgerExerciseSearchView(model: model, allMuscles: allMuscles, allCategories: categories)
            }
        }
    }

    private func muscleGroupSection(
        titleKey: LocalizedStringKey,
        muscles: Set<Muscle>,
        color: Color,
        removeLabelKey: String,
        group: ExerciseEditorModel.MuscleSelectionGroup
    ) -> some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(muscles.sorted(by: { $0.displayName < $1.displayName })) { muscle in
                        MuscleChip(
                            muscle: muscle,
                            color: color,
                            removeAccessibilityLabel: String(
                                format: NSLocalizedString(removeLabelKey, comment: ""),
                                muscle.displayName
                            ),
                            onRemove: { model.toggle(muscle, in: group) }
                        )
                    }

                    MuscleChipAddButton {
                        pickerGroup = group
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        } header: {
            sectionHeader(titleKey)
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(Typography.caption)
            .foregroundStyle(Color("textSecondary"))
    }

    private func legendItem(color: Color, titleKey: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(titleKey)
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
        }
    }

    private func save() {
        do {
            try model.save(context: modelContext)
            dismiss()
        } catch {
            // Save failure is logged inside ExerciseEditorModel; the sheet stays open so the
            // developer can retry rather than silently losing the entered data.
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return ExerciseEditorView()
        .modelContainer(container)
}
