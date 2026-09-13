//
//  RecordsView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct RecordsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var records: [PersonalRecord]
    @State private var model = RecordsModel()
    @State private var isPresentingPicker = false
    @State private var editingRecord: PersonalRecord?
    @State private var creatingForExercise: Exercise?

    var body: some View {
        let sorted = model.sortedRecords(from: records)

        NavigationStack {
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
                        Button {
                            editingRecord = record
                        } label: {
                            RecordRow(record: record)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .background(Color("appBackground"))
                }
            }
            .navigationTitle("records.title")
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("screen.records")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("records.close")
                }

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
            .sheet(item: $editingRecord) { record in
                RecordEditorView(exercise: record.exercise, record: record)
            }
            .sheet(item: $creatingForExercise) { exercise in
                RecordEditorView(exercise: exercise)
            }
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return RecordsView()
        .modelContainer(container)
}
