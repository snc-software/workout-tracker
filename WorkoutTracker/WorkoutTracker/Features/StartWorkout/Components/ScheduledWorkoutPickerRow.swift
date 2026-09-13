//
//  ScheduledWorkoutPickerRow.swift
//  WorkoutTracker
//

import SwiftUI

/// A selectable row in `StartWorkoutScheduleListView`, matching `ScheduleDayRow`'s content styling
/// without its edit/add affordances, which don't apply to a selection list.
struct ScheduledWorkoutPickerRow: View {
    let day: DayOfWeek
    let workout: ScheduledWorkout
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(day.shortLabel)
                    .font(Typography.h5)
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: 40, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.displayTitle)
                        .font(Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("textPrimary"))
                    Text("^[\(workout.exercises.count) exercise](inflect: true)")
                        .font(Typography.caption)
                        .foregroundStyle(Color("textSecondary"))
                }

                Spacer()
            }
            .padding(12)
            .background(Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("border"), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("startWorkout.scheduleList.day.\(day.shortLabel)")
    }
}
