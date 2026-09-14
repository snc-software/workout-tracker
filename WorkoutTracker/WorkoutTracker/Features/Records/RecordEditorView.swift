//
//  RecordEditorView.swift
//  WorkoutTracker
//

import Foundation
import Iconoir
import SwiftData
import SwiftUI

struct RecordEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var model: RecordEditorModel

    init(exercise: Exercise, record: PersonalRecord? = nil) {
        _model = State(initialValue: RecordEditorModel(exercise: exercise, record: record))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(model.exercise.name)
                        .font(Typography.body)
                        .foregroundStyle(Color("textPrimary"))
                } header: {
                    sectionHeader("records.editor.exercise.label")
                }

                Section {
                    TextField("", value: $model.weightKg, format: .number)
                        .keyboardType(.decimalPad)
                        .font(Typography.body)
                        .accessibilityLabel("records.editor.weight.label")
                        .accessibilityIdentifier("records.editor.weight.field")
                } header: {
                    sectionHeader("records.editor.weight.label")
                }
            }
            .navigationTitle(model.isEditing ? "records.editor.edit.title" : "records.editor.add.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("records.editor.cancel")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        save()
                    } label: {
                        Text("records.editor.save").font(Typography.body)
                    }
                    .disabled(!model.canSave)
                    .accessibilityIdentifier("records.editor.save")
                }
            }
        }
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(Typography.caption)
            .foregroundStyle(Color("textSecondary"))
    }

    private func save() {
        do {
            try model.save(context: modelContext)
            dismiss()
        } catch {
            // Save failure is logged inside RecordEditorModel; the sheet stays open so the
            // developer can retry rather than silently losing the entered data.
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    let exercise = Exercise(name: "Bench Press")
    container.mainContext.insert(exercise)

    return RecordEditorView(exercise: exercise)
        .modelContainer(container)
}
