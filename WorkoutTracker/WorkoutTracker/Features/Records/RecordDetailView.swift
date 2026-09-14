//
//  RecordDetailView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Pushed from `RecordsView` onto the tab's existing `NavigationStack` — not presented as a sheet, so it
/// gets the system back button for free, matching `HistoryDetailView`'s equivalent.
struct RecordDetailView: View {
    let record: PersonalRecord
    @State private var isPresentingEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("records.detail.record.label")
                    PersonalRecordBadge(weightKg: record.weightKg)
                }

                if let workoutLog = record.achievedInWorkout {
                    VStack(alignment: .leading, spacing: 8) {
                        sectionHeader("records.detail.achieved.label")
                        NavigationLink {
                            SessionSummaryView(model: SessionSummaryModel(workoutLog: workoutLog), onFinish: nil)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            achievedWorkoutPanel(workoutLog)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("records.detail.viewWorkout")
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color("appBackground"))
        .navigationTitle(record.exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.recordDetail")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Text("records.detail.edit").font(Typography.body)
                }
                .accessibilityIdentifier("records.detail.edit")
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            RecordEditorView(exercise: record.exercise, record: record)
        }
    }

    private func achievedWorkoutPanel(_ workoutLog: WorkoutLog) -> some View {
        HStack(spacing: 12) {
            Iconoir.clockRotateRight.asImage
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(workoutLog.displayTitle)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))
                if let finishedAt = workoutLog.finishedAt {
                    Text(finishedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(Typography.caption)
                        .foregroundStyle(Color("textSecondary"))
                }
            }
            Spacer()
            Iconoir.navArrowRight.asImage
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("border"), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(Typography.caption)
            .foregroundStyle(Color("textSecondary"))
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    let exercise = Exercise(name: "Bench Press")
    let record = PersonalRecord(exercise: exercise, weightKg: 82.5)
    container.mainContext.insert(record)

    return NavigationStack {
        RecordDetailView(record: record)
    }
    .modelContainer(container)
}
