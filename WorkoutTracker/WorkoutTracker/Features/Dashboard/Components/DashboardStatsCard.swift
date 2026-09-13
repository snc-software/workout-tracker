//
//  DashboardStatsCard.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct DashboardStatsCard: View {
    let stats: DashboardStats

    private var workoutsText: String {
        stats.workoutsThisWeek.formatted()
    }

    private var weightLiftedText: String {
        Int(stats.weightLiftedThisWeekKg.rounded()).formatted()
    }

    private var streakText: String {
        stats.consecutiveWeekStreak.formatted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("dashboard.stats.title")
                .font(Typography.overline)
                .textCase(.uppercase)
                .foregroundStyle(Color("textSecondary"))

            HStack(spacing: 8) {
                StatTile(
                    icon: .calendar,
                    value: workoutsText,
                    label: "dashboard.stats.workouts",
                    accessibilityLabel: String(
                        format: NSLocalizedString("dashboard.stats.workouts.accessibilityLabel", comment: ""),
                        workoutsText
                    ),
                    identifier: "dashboard.stat.workouts",
                    isBordered: false
                )
                StatTile(
                    icon: .weight,
                    value: weightLiftedText,
                    label: "dashboard.stats.weightLifted",
                    accessibilityLabel: String(
                        format: NSLocalizedString("dashboard.stats.weightLifted.accessibilityLabel", comment: ""),
                        weightLiftedText
                    ),
                    identifier: "dashboard.stat.weightLifted",
                    isBordered: false
                )
                StatTile(
                    icon: .fireFlame,
                    value: streakText,
                    label: "dashboard.stats.streak",
                    accessibilityLabel: String(
                        format: NSLocalizedString("dashboard.stats.streak.accessibilityLabel", comment: ""),
                        streakText
                    ),
                    identifier: "dashboard.stat.streak",
                    isBordered: false
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }
}

#Preview {
    DashboardStatsCard(
        stats: DashboardStats(workoutsThisWeek: 3, weightLiftedThisWeekKg: 18450, consecutiveWeekStreak: 4)
    )
    .padding()
}
