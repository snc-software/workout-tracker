//
//  UpcomingWorkoutCard.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct UpcomingWorkoutCard: View {
    let workout: ScheduledWorkout
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("dashboard.startTodayWorkout.title")
                        .font(Typography.overline)
                        .textCase(.uppercase)
                        .foregroundStyle(Color("primaryBrand"))
                    Text(workout.displayTitle)
                        .font(Typography.body)
                        .foregroundStyle(Color("textPrimary"))
                }
                Spacer()
                Iconoir.playSolid.asImage
                    .foregroundStyle(Color("primaryBrand"))
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(Color("primarySubtleBg"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("primaryBrand"), lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.startTodayWorkout")
    }
}

#Preview {
    UpcomingWorkoutCard(workout: ScheduledWorkout(dayOfWeek: .today, name: "Bench Press"), action: {})
        .padding()
}
