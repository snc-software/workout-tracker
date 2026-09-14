//
//  WorkoutLogExercisePickerView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Sheet content for quick-adding an exercise mid-log. Uses a custom search field rather than
/// `.searchable`, matching `ExercisePickerView`/`RecordExercisePickerView`'s established approach.
struct WorkoutLogExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @State private var searchText = ""
    @State private var isPresentingQuickCreate = false
    @FocusState private var isSearchFieldFocused: Bool

    let model: WorkoutLogModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchField

                if availableExercises.isEmpty {
                    emptyState
                } else {
                    resultsList
                }
            }
            .padding(.top, 8)
            .navigationTitle("workoutLog.picker.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("workoutLog.picker.close")
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingQuickCreate = true
                    } label: {
                        Iconoir.plus.asImage
                    }
                    .accessibilityIdentifier("workoutLog.picker.quickCreate")
                    .accessibilityLabel("workoutLog.picker.quickCreate.label")
                }
            }
        }
        .sheet(isPresented: $isPresentingQuickCreate) {
            ExerciseEditorView(onSave: { exercise in
                model.addExercise(exercise)
                dismiss()
            })
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Iconoir.search.asImage
                .foregroundStyle(Color("textSecondary"))

            TextField("workoutLog.picker.search.prompt", text: $searchText)
                .font(Typography.body)
                .focused($isSearchFieldFocused)
                .accessibilityIdentifier("workoutLog.picker.search.field")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFieldFocused = false
                } label: {
                    Iconoir.xmark.asImage
                        .foregroundStyle(Color("textSecondary"))
                }
                .accessibilityLabel("workoutLog.picker.search.clear")
            }
        }
        .padding(10)
        .background(Color("border").opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    private var resultsList: some View {
        List(availableExercises) { exercise in
            Button {
                model.addExercise(exercise)
                dismiss()
            } label: {
                Text(exercise.name)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))
            }
            .accessibilityIdentifier("workoutLog.picker.result.\(exercise.name)")
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Iconoir.search.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("workoutLog.picker.empty.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("workoutLog.picker.empty.subtitle")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var availableExercises: [Exercise] {
        let contained = model.containedExercises
        let notYetAdded = allExercises.filter { !contained.contains($0) }
        guard !searchText.isEmpty else { return notYetAdded }
        return notYetAdded.filter { $0.name.localizedStandardContains(searchText) }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return WorkoutLogExercisePickerView(model: WorkoutLogModel(source: .custom))
        .modelContainer(container)
}
