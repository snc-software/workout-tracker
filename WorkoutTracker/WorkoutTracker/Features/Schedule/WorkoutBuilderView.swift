//
//  WorkoutBuilderView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct WorkoutBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var model: WorkoutBuilderModel
    @State private var isReordering = false
    @State private var isPresentingExercisePicker = false

    init(day: DayOfWeek, workout: ScheduledWorkout? = nil) {
        _model = State(initialValue: WorkoutBuilderModel(day: day, workout: workout))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("", text: $model.name)
                        .font(Typography.body)
                        .padding(12)
                        .background(Color("surface"))
                        .clipShape(Capsule())
                        .accessibilityIdentifier("schedule.builder.name.field")
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                } header: {
                    sectionHeader("schedule.builder.name.placeholder")
                }

                Section {
                    ForEach(model.blocks) { block in
                        WorkoutBuilderBlockRow(block: block, model: model, isReordering: isReordering)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .onMove(perform: model.moveBlock)

                    if !model.isSelectingForSuperset, !isReordering {
                        addExerciseButton
                    }

                    if !isReordering {
                        groupingControl
                    }

                    if !model.isSelectingForSuperset, !isReordering {
                        removeAllButton
                    }
                } header: {
                    sectionHeader("schedule.builder.exercises.header")
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color("appBackground"))
            .environment(\.editMode, .constant(isReordering ? .active : .inactive))
            .navigationTitle(model.day.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("schedule.builder.close")
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        isReordering.toggle()
                    } label: {
                        Text(isReordering ? "schedule.builder.reorder.done" : "schedule.builder.reorder")
                            .font(Typography.body)
                    }
                    .disabled(model.isSelectingForSuperset)
                    .accessibilityIdentifier("schedule.builder.reorder.toggle")

                    Button {
                        save()
                    } label: {
                        Text("schedule.builder.save").font(Typography.body)
                    }
                    .disabled(!model.canSave || model.isSelectingForSuperset)
                    .accessibilityIdentifier("schedule.builder.save")
                }
            }
            .sheet(isPresented: $isPresentingExercisePicker) {
                ExercisePickerView(model: model)
            }
        }
    }

    private var addExerciseButton: some View {
        Button {
            isPresentingExercisePicker = true
        } label: {
            HStack {
                Iconoir.plus.asImage
                Text("schedule.builder.addExercise")
            }
            .font(Typography.body)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
            .frame(maxWidth: .infinity)
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color("border"), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
        )
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("schedule.builder.addExercise")
    }

    @ViewBuilder
    private var groupingControl: some View {
        if model.isSelectingForSuperset {
            HStack {
                Button("schedule.builder.grouping.cancel") {
                    model.cancelGrouping()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color("textSecondary"))
                .accessibilityIdentifier("schedule.builder.grouping.cancel")
                Spacer()
                Button("schedule.builder.grouping.confirm") {
                    model.confirmGrouping()
                }
                .buttonStyle(.plain)
                .disabled(!model.canConfirmGrouping)
                .foregroundStyle(Color("accent"))
                .accessibilityIdentifier("schedule.builder.grouping.confirm")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
            .listRowSeparator(.hidden)
        } else if model.blocks.count >= 2 {
            Button {
                model.beginGrouping()
            } label: {
                HStack {
                    Iconoir.link.asImage
                    Text("schedule.builder.groupIntoSuperset")
                }
                .font(Typography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color("accent"))
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
            .accessibilityIdentifier("schedule.builder.groupIntoSuperset")
        }
    }

    private var removeAllButton: some View {
        Button(role: .destructive) {
            model.removeAll()
        } label: {
            HStack {
                Iconoir.trash.asImage
                Text("schedule.builder.removeAll")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
        }
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity)
        .disabled(model.entries.isEmpty)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 8, trailing: 16))
        .accessibilityIdentifier("schedule.builder.removeAll")
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
            // Save failure is logged inside WorkoutBuilderModel; the sheet stays open so the
            // developer can retry rather than silently losing the entered data.
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return WorkoutBuilderView(day: .wednesday)
        .modelContainer(container)
}
