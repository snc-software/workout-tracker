//
//  StartWorkoutScheduleListView.swift
//  WorkoutTracker
//

import SwiftData
import SwiftUI

/// Pushed from `StartWorkoutView`'s "Choose Workout" option: lets the developer pick any day that
/// currently has a scheduled workout.
struct StartWorkoutScheduleListView: View {
    let workouts: [ScheduledWorkout]
    let scheduleModel: ScheduleModel
    let onSelect: (WorkoutLogModel.Source) -> Void

    var body: some View {
        List {
            if scheduledDays.isEmpty {
                emptyState
            } else {
                ForEach(scheduledDays, id: \.self) { day in
                    if let workout = scheduleModel.workout(for: day, in: workouts) {
                        ScheduledWorkoutPickerRow(day: day, workout: workout) {
                            onSelect(.scheduled(workout))
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color("appBackground"))
        .navigationTitle("startWorkout.chooseWorkout.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.startWorkout.scheduleList")
    }

    private var scheduledDays: [DayOfWeek] {
        scheduleModel.scheduledDays(from: workouts)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("startWorkout.scheduleList.empty.title")
                .font(Typography.h4)
                .foregroundStyle(Color("textPrimary"))
            Text("startWorkout.scheduleList.empty.subtitle")
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        StartWorkoutScheduleListView(workouts: [], scheduleModel: ScheduleModel(), onSelect: { _ in })
    }
    .modelContainer(container)
}
