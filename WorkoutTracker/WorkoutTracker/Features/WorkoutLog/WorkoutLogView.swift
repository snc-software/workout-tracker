//
//  WorkoutLogView.swift
//  WorkoutTracker
//

import Foundation
import Iconoir
import SwiftData
import SwiftUI

struct WorkoutLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var model: WorkoutLogModel
    @State private var isPresentingExercisePicker = false
    @State private var summaryModel: SessionSummaryModel?

    init(source: WorkoutLogModel.Source) {
        _model = State(initialValue: WorkoutLogModel(source: source))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let summaryModel {
                    SessionSummaryView(model: summaryModel) {
                        dismiss()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    loggingContent
                }
            }
            .animation(.default, value: summaryModel == nil)
        }
    }

    private var loggingContent: some View {
        List {
            Section {
                elapsedTimeLabel
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(model.blocks) { block in
                    WorkoutLogExerciseSection(block: block, model: model)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

                if !model.isSelectingForSuperset {
                    addExerciseButton
                }

                groupingControl
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("appBackground"))
        .navigationTitle(model.name ?? String(localized: "workoutLog.custom.title"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.workoutLog")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Iconoir.xmark.asImage
                }
                .accessibilityLabel("workoutLog.cancel")
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                } label: {
                    Text("workoutLog.finish").font(Typography.body)
                }
                .disabled(!model.canSave || model.isSelectingForSuperset)
                .accessibilityIdentifier("workoutLog.finish")
            }
        }
        .sheet(isPresented: $isPresentingExercisePicker) {
            WorkoutLogExercisePickerView(model: model)
        }
    }

    private var elapsedTimeLabel: some View {
        TimelineView(.periodic(from: model.startedAt, by: 1)) { context in
            let elapsedSeconds = max(context.date.timeIntervalSince(model.startedAt), 0)
            let formatted = Duration.seconds(elapsedSeconds).formatted(.time(pattern: .minuteSecond))
            Text(String(format: NSLocalizedString("workoutLog.elapsed.label", comment: ""), formatted))
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
                .accessibilityIdentifier("workoutLog.elapsed")
        }
    }

    private var addExerciseButton: some View {
        Button {
            isPresentingExercisePicker = true
        } label: {
            HStack {
                Iconoir.plus.asImage
                Text("workoutLog.addExercise")
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
        .accessibilityIdentifier("workoutLog.addExercise")
    }

    @ViewBuilder
    private var groupingControl: some View {
        if model.isSelectingForSuperset {
            HStack {
                Button("workoutLog.grouping.cancel") {
                    model.cancelGrouping()
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color("textSecondary"))
                .accessibilityIdentifier("workoutLog.grouping.cancel")
                Spacer()
                Button("workoutLog.grouping.confirm") {
                    model.confirmGrouping()
                }
                .buttonStyle(.plain)
                .disabled(!model.canConfirmGrouping)
                .foregroundStyle(Color("accent"))
                .accessibilityIdentifier("workoutLog.grouping.confirm")
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
                    Text("workoutLog.groupIntoSuperset")
                }
                .font(Typography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color("accent"))
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
            .accessibilityIdentifier("workoutLog.groupIntoSuperset")
        }
    }

    private func save() {
        do {
            let log = try model.save(context: modelContext)
            summaryModel = SessionSummaryModel(workoutLog: log)
        } catch {
            // Save failure is logged inside WorkoutLogModel; the logging screen stays open so the developer
            // can retry rather than silently losing the entered data.
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return WorkoutLogView(source: .custom)
        .modelContainer(container)
}
