//
//  RecordExercisePickerView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Sheet content for "Add record". Uses a custom search field rather than `.searchable`, matching
/// `ExercisePickerView`'s approach, which didn't reliably resign focus/dismiss its keyboard when
/// embedded in this sheet's fixed layout.
struct RecordExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool

    let onSelect: (Exercise) -> Void

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
            .navigationTitle("records.picker.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("records.picker.close")
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Iconoir.search.asImage
                .foregroundStyle(Color("textSecondary"))

            TextField("records.picker.search.prompt", text: $searchText)
                .font(Typography.body)
                .focused($isSearchFieldFocused)
                .accessibilityIdentifier("records.picker.search.field")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isSearchFieldFocused = false
                } label: {
                    Iconoir.xmark.asImage
                        .foregroundStyle(Color("textSecondary"))
                }
                .accessibilityLabel("records.picker.search.clear")
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
                onSelect(exercise)
                dismiss()
            } label: {
                Text(exercise.name)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))
            }
            .accessibilityIdentifier("records.picker.result.\(exercise.name)")
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Iconoir.search.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("records.picker.empty.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("records.picker.empty.subtitle")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var availableExercises: [Exercise] {
        let withoutRecord = allExercises.filter { $0.personalRecord == nil }
        guard !searchText.isEmpty else { return withoutRecord }
        return withoutRecord.filter { $0.name.localizedStandardContains(searchText) }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return RecordExercisePickerView(onSelect: { _ in })
        .modelContainer(container)
}
