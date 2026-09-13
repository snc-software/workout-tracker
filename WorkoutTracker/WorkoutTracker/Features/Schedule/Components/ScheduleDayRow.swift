//
//  ScheduleDayRow.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct ScheduleDayRow: View {
    let day: DayOfWeek
    let workout: ScheduledWorkout?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text(day.shortLabel)
                    .font(Typography.h5)
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: 40, alignment: .leading)

                content

                Spacer()

                action
            }
            .padding(12)
            .background(workout == nil ? Color("surfaceAccent") : Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(workout == nil ? .clear : Color("border"), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("schedule.day.\(day.shortLabel)")
    }

    @ViewBuilder
    private var content: some View {
        if let workout {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.displayTitle)
                    .font(Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("textPrimary"))
                Text("^[\(workout.exercises.count) exercise](inflect: true)")
                    .font(Typography.caption)
                    .foregroundStyle(Color("textSecondary"))
            }
        } else {
            Text("schedule.day.empty")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
        }
    }

    @ViewBuilder
    private var action: some View {
        if workout != nil {
            HStack(spacing: 4) {
                Iconoir.editPencil.asImage
                Text("schedule.day.edit")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
        } else {
            HStack(spacing: 4) {
                Iconoir.plus.asImage
                Text("schedule.day.add")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color("border"), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
            )
        }
    }
}
