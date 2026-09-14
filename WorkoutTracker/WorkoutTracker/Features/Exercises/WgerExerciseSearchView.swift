//
//  WgerExerciseSearchView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

/// Sheet content for searching wger's exercise database and pre-filling the editor from a match. Mirrors
/// `MuscleGroupPickerView`'s search-field structure, but queries the network (debounced via `.task(id:)`)
/// instead of filtering an in-memory list.
struct WgerExerciseSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool

    let model: ExerciseEditorModel
    let allMuscles: [Muscle]
    let allCategories: [ExerciseCategory]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchField
                content
            }
            .padding(.top, 8)
            .navigationTitle("exercises.editor.wger.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("exercises.editor.wger.cancel")
                }
            }
            .task(id: searchText) {
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
                await model.searchWger(matching: searchText)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.wgerSearchState {
        case .idle:
            stateMessage(
                icon: .globe,
                titleKey: "exercises.editor.wger.idle.title",
                subtitleKey: "exercises.editor.wger.idle.subtitle"
            )
        case .searching:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .loaded(matches):
            resultsList(matches)
        case .empty:
            stateMessage(
                icon: .search,
                titleKey: "exercises.editor.wger.empty.title",
                subtitleKey: "exercises.editor.wger.empty.subtitle"
            )
        case .failed:
            stateMessage(
                icon: .warningTriangle,
                titleKey: "exercises.editor.wger.error.title",
                subtitleKey: "exercises.editor.wger.error.subtitle"
            )
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Iconoir.search.asImage
                .foregroundStyle(Color("textSecondary"))

            TextField("exercises.editor.wger.search.prompt", text: $searchText)
                .font(Typography.body)
                .focused($isSearchFieldFocused)
                .accessibilityIdentifier("exercises.editor.wger.search.field")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFieldFocused = false
                } label: {
                    Iconoir.xmark.asImage
                        .foregroundStyle(Color("textSecondary"))
                }
                .accessibilityLabel("exercises.editor.wger.search.clear")
            }
        }
        .padding(10)
        .background(Color("border").opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    private func resultsList(_ matches: [WgerExerciseMatch]) -> some View {
        List(matches) { match in
            Button {
                model.applyWgerMatch(match, allMuscles: allMuscles, allCategories: allCategories)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name)
                        .font(Typography.body)
                        .foregroundStyle(Color("textPrimary"))

                    let muscleNames = displayNames(for: match.primaryMuscleNames + match.secondaryMuscleNames)
                    if !muscleNames.isEmpty {
                        Text(muscleNames.joined(separator: ", "))
                            .font(Typography.caption)
                            .foregroundStyle(Color("textSecondary"))
                    }
                }
            }
            .accessibilityIdentifier("exercises.editor.wger.result.\(match.name)")
        }
        .listStyle(.plain)
    }

    private func stateMessage(
        icon: Iconoir,
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey
    ) -> some View {
        VStack(spacing: 12) {
            icon.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text(titleKey)
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text(subtitleKey)
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func displayNames(for regionNames: [String]) -> [String] {
        regionNames.compactMap { regionName in
            allMuscles.first(where: { $0.name == regionName })?.displayName
        }
    }
}
