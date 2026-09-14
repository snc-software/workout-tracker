//
//  RecordsView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Pushed from the Dashboard's "Records" button, onto that tab's existing `NavigationStack` — not
/// presented as a sheet, so it gets the system back button for free.
struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [PersonalRecord]
    @State private var model = RecordsModel()
    @State private var isPresentingPicker = false
    @State private var creatingForExercise: Exercise?

    var body: some View {
        let sorted = model.sortedRecords(from: records)

        Group {
            if sorted.isEmpty {
                VStack(spacing: 12) {
                    Iconoir.starSolid.asImage
                        .font(.system(size: 40))
                        .foregroundStyle(Color("textSecondary"))
                        .accessibilityHidden(true)
                    Text("records.empty.title")
                        .font(Typography.h2)
                        .foregroundStyle(Color("textPrimary"))
                    Text("records.empty.subtitle")
                        .font(Typography.body)
                        .foregroundStyle(Color("textSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("appBackground"))
            } else {
                List(sorted) { record in
                    NavigationLink {
                        RecordDetailView(record: record)
                    } label: {
                        RecordRow(record: record)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteRecord(record)
                        } label: {
                            Label {
                                Text("records.delete")
                            } icon: {
                                Iconoir.trash.asImage
                            }
                        }
                        .accessibilityIdentifier("records.row.delete")
                    }
                }
                .listStyle(.plain)
                .background(Color("appBackground"))
            }
        }
        .navigationTitle("records.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.records")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingPicker = true
                } label: {
                    Iconoir.plus.asImage
                }
                .accessibilityIdentifier("records.addButton")
                .accessibilityLabel("records.addButton.label")
            }
        }
        .sheet(isPresented: $isPresentingPicker) {
            RecordExercisePickerView { exercise in
                creatingForExercise = exercise
            }
        }
        .sheet(item: $creatingForExercise) { exercise in
            RecordEditorView(exercise: exercise)
        }
    }

    private func deleteRecord(_ record: PersonalRecord) {
        try? model.deleteRecord(record, context: modelContext)
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        RecordsView()
    }
    .modelContainer(container)
}
