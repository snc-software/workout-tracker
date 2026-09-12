//
//  MuscleGroupPickerView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

/// Sheet content for adding/removing muscles in one selection group. Deals only in our own
/// `Muscle` type — `MuscleMapPicker` has already resolved any tap back from the third-party
/// library before this view ever sees it.
///
/// Searching by name toggles the same selection a map tap would, so picking a result "populates"
/// the map — useful when you know the muscle by name but not where it sits on the diagram. Uses a
/// custom search field rather than `.searchable`, which didn't reliably resign focus/dismiss its
/// keyboard when embedded in this sheet's fixed (non-scrolling) layout.
struct MuscleGroupPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool

    let group: ExerciseEditorModel.MuscleSelectionGroup
    let model: ExerciseEditorModel
    let allMuscles: [Muscle]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchField

                if searchText.isEmpty {
                    MuscleMapPicker(
                        allMuscles: allMuscles,
                        primaryMuscles: Array(model.primaryMuscles),
                        secondaryMuscles: Array(model.secondaryMuscles),
                        onMuscleTapped: { muscle in
                            model.toggle(muscle, in: group)
                        }
                    )
                    .padding(.horizontal)
                } else if filteredMuscles.isEmpty {
                    emptySearchState
                } else {
                    searchResultsList
                }
            }
            .padding(.top, 8)
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

    private var searchField: some View {
        HStack(spacing: 8) {
            Iconoir.search.asImage
                .foregroundStyle(Color("textSecondary"))

            TextField("exercises.editor.picker.search.prompt", text: $searchText)
                .font(Typography.body)
                .focused($isSearchFieldFocused)
                .accessibilityIdentifier("exercises.editor.picker.search.field")

            if !searchText.isEmpty {
                Button {
                    collapseSearch()
                } label: {
                    Iconoir.xmark.asImage
                        .foregroundStyle(Color("textSecondary"))
                }
                .accessibilityLabel("exercises.editor.picker.search.clear")
            }
        }
        .padding(10)
        .background(Color("border").opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    private var searchResultsList: some View {
        List(filteredMuscles) { muscle in
            Button {
                model.toggle(muscle, in: group)
                collapseSearch()
            } label: {
                HStack {
                    Text(muscle.displayName)
                        .font(Typography.body)
                        .foregroundStyle(Color("textPrimary"))
                    Spacer()
                    if isSelected(muscle) {
                        Iconoir.check.asImage
                            .foregroundStyle(Color("primaryBrand"))
                    }
                }
            }
            .accessibilityIdentifier("exercises.editor.picker.result.\(muscle.displayName)")
            .accessibilityValue(isSelected(muscle) ? Text("exercises.editor.picker.search.selected") : Text(""))
        }
        .listStyle(.plain)
    }

    private var emptySearchState: some View {
        VStack(spacing: 12) {
            Iconoir.search.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("exercises.editor.picker.search.empty.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("exercises.editor.picker.search.empty.subtitle")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var filteredMuscles: [Muscle] {
        allMuscles
            .filter { $0.displayName.localizedStandardContains(searchText) }
            .sorted { $0.displayName < $1.displayName }
    }

    private func isSelected(_ muscle: Muscle) -> Bool {
        switch group {
        case .primary: model.primaryMuscles.contains(muscle)
        case .secondary: model.secondaryMuscles.contains(muscle)
        }
    }

    private func collapseSearch() {
        searchText = ""
        isSearchFieldFocused = false
    }

    private var titleKey: LocalizedStringKey {
        switch group {
        case .primary: return "exercises.editor.picker.primary.title"
        case .secondary: return "exercises.editor.picker.secondary.title"
        }
    }
}
