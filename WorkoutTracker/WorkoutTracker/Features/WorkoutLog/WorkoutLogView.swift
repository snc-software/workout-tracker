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
    @State private var finishedAt: Date
    @State private var isPresentingExercisePicker = false
    @State private var summaryModel: SessionSummaryModel?

    /// `true` when this session is being logged after the fact rather than live: swaps the elapsed-timer
    /// for start/end date pickers, and `save()` uses the picked `finishedAt` instead of `Date()`.
    let isHistorical: Bool

    /// Non-`nil` only for a live session owned by an `ActiveWorkoutSession`: shows the minimise chevron
    /// and, when tapped, hands control back to the session instead of dismissing this screen.
    let onMinimize: (() -> Void)?
    /// Called once the session genuinely ends (cancelled, or saved), so the owning `ActiveWorkoutSession`
    /// can clear its model and stop showing the minimised pill.
    let onEnd: (() -> Void)?

    /// `true` only for `init(editing:)`: saving returns straight to the caller (the history detail
    /// screen already shows the up-to-date summary) instead of showing a summary screen on top of it.
    private let isEditingExisting: Bool

    init(source: WorkoutLogModel.Source, performedAt: Date? = nil) {
        let startedAt = performedAt ?? Date()
        _model = State(initialValue: WorkoutLogModel(source: source, startedAt: startedAt))
        _finishedAt = State(initialValue: startedAt)
        isHistorical = performedAt != nil
        onMinimize = nil
        onEnd = nil
        isEditingExisting = false
    }

    /// Used for a live session whose `WorkoutLogModel` is owned by an `ActiveWorkoutSession` rather than
    /// by this View, so the same model instance survives being minimised into the tab-bar pill and later
    /// maximised back to this screen.
    init(model: WorkoutLogModel, onMinimize: @escaping () -> Void, onEnd: @escaping () -> Void) {
        _model = State(initialValue: model)
        _finishedAt = State(initialValue: model.startedAt)
        isHistorical = false
        self.onMinimize = onMinimize
        self.onEnd = onEnd
        isEditingExisting = false
    }

    /// Edits an already-saved historical `log` in place, pre-loaded with its existing exercises, sets,
    /// and dates. Reuses the historical UI (date pickers, "Save" label) since an edited entry isn't live.
    init(editing log: WorkoutLog) {
        _model = State(initialValue: WorkoutLogModel(editing: log))
        _finishedAt = State(initialValue: log.finishedAt ?? log.startedAt)
        isHistorical = true
        onMinimize = nil
        onEnd = nil
        isEditingExisting = true
    }

    var body: some View {
        NavigationStack {
            Group {
                if let summaryModel {
                    SessionSummaryView(model: summaryModel) {
                        onEnd?()
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
                if isHistorical {
                    performedAtPickers
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    elapsedTimeLabel
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
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
            if let onMinimize {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onMinimize) {
                        Iconoir.navArrowDown.asImage
                    }
                    .accessibilityLabel("workoutLog.minimize")
                    .accessibilityIdentifier("workoutLog.minimize")
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onEnd?()
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
                    Text(isHistorical ? "workoutLog.saveHistorical" : "workoutLog.finish").font(Typography.body)
                }
                .disabled(!model.canSave || model.isSelectingForSuperset)
                .accessibilityIdentifier("workoutLog.finish")
            }
        }
        .sheet(isPresented: $isPresentingExercisePicker) {
            WorkoutLogExercisePickerView(model: model)
        }
    }

    private var performedAtPickers: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                "workoutLog.performedAt.start.label",
                selection: $model.startedAt,
                in: ...min(finishedAt, Date()),
                displayedComponents: [.date, .hourAndMinute]
            )
            .accessibilityIdentifier("workoutLog.performedAt.start")

            DatePicker(
                "workoutLog.performedAt.end.label",
                selection: $finishedAt,
                in: model.startedAt ... Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .accessibilityIdentifier("workoutLog.performedAt.end")
        }
        .font(Typography.caption)
        .foregroundStyle(Color("textSecondary"))
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
            let log = try model.save(context: modelContext, finishedAt: isHistorical ? finishedAt : Date())
            if isEditingExisting {
                onEnd?()
                dismiss()
            } else {
                summaryModel = SessionSummaryModel(workoutLog: log)
            }
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
