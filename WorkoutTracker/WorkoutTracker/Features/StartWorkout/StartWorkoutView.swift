//
//  StartWorkoutView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Sheet content for the Dashboard's "Start Workout" button: offers today's scheduled workout (when one
/// exists), picking any other day's schedule, or starting a blank custom session.
struct StartWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var workouts: [ScheduledWorkout]
    @State private var scheduleModel = ScheduleModel()

    let onSelect: (WorkoutLogModel.Source) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let todayWorkout = scheduleModel.workout(for: .today, in: workouts) {
                    startTodayButton(for: todayWorkout)
                }

                chooseWorkoutCard
                customCard

                Spacer()
            }
            .padding()
            .background(Color("appBackground"))
            .navigationTitle("startWorkout.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Iconoir.xmark.asImage
                    }
                    .accessibilityLabel("startWorkout.close")
                }
            }
        }
        .accessibilityIdentifier("screen.startWorkout")
    }

    private func startTodayButton(for workout: ScheduledWorkout) -> some View {
        Button {
            select(.scheduled(workout))
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Iconoir.playSolid.asImage
                    Text("startWorkout.startToday.title")
                        .font(Typography.h4)
                }
                Text("startWorkout.startToday.subtitle")
                    .font(Typography.caption)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(Color("primaryBrand"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityIdentifier("startWorkout.startToday")
    }

    private var chooseWorkoutCard: some View {
        NavigationLink {
            StartWorkoutScheduleListView(workouts: workouts, scheduleModel: scheduleModel, onSelect: select)
        } label: {
            optionCard(
                icon: Iconoir.calendar,
                title: "startWorkout.chooseWorkout.title",
                subtitle: "startWorkout.chooseWorkout.subtitle"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("startWorkout.chooseWorkout")
    }

    private var customCard: some View {
        Button {
            select(.custom)
        } label: {
            optionCard(
                icon: Iconoir.editPencil,
                title: "startWorkout.custom.title",
                subtitle: "startWorkout.custom.subtitle"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("startWorkout.custom")
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

    return StartWorkoutView(onSelect: { _ in })
        .modelContainer(container)
}
