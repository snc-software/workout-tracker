//
//  HistoryAddWorkoutSourceView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Sheet content for `HistoryView`'s "+" button: pick a scheduled workout to pre-load exercises from, or
/// start blank. No "start today" shortcut here (unlike `StartWorkoutView`) — every path through this flow
/// still needs the date/time picker on the next screen, since the whole point is logging a past session.
struct HistoryAddWorkoutSourceView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [ScheduledWorkout]
    @State private var scheduleModel = ScheduleModel()

    let onSelect: (WorkoutLogModel.Source) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                chooseWorkoutCard
                customCard
                Spacer()
            }
            .padding()
            .background(Color("appBackground"))
            .navigationTitle("history.addWorkout.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("history.addWorkout.close")
                }
            }
        }
        .accessibilityIdentifier("screen.history.addWorkout")
    }

    private var chooseWorkoutCard: some View {
        NavigationLink {
            StartWorkoutScheduleListView(workouts: workouts, scheduleModel: scheduleModel, onSelect: select)
        } label: {
            optionCard(
                icon: Iconoir.calendar,
                title: "history.addWorkout.chooseWorkout.title",
                subtitle: "history.addWorkout.chooseWorkout.subtitle"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("history.addWorkout.chooseWorkout")
    }

    private var customCard: some View {
        Button {
            select(.custom)
        } label: {
            optionCard(
                icon: Iconoir.editPencil,
                title: "history.addWorkout.custom.title",
                subtitle: "history.addWorkout.custom.subtitle"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("history.addWorkout.custom")
    }

    private func optionCard(icon: Iconoir, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            icon.asImage
                .foregroundStyle(Color("textSecondary"))
            Text(title)
                .font(Typography.h4)
                .foregroundStyle(Color("textPrimary"))
            Text(subtitle)
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }

    private func select(_ source: WorkoutLogModel.Source) {
        onSelect(source)
        dismiss()
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return HistoryAddWorkoutSourceView(onSelect: { _ in })
        .modelContainer(container)
}
