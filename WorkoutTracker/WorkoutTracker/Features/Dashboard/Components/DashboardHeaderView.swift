//
//  DashboardHeaderView.swift
//  WorkoutTracker
//

import SwiftUI

struct DashboardHeaderView: View {
    let greetingPeriod: GreetingPeriod
    let date: Date
    var name: String = ""

    /// Resolved via `NSLocalizedString`/`String(format:)`, matching this app's other symbolic-key +
    /// runtime-argument localizations (see `SessionSummaryView`'s accessibility labels), since this
    /// codebase's keys are dot-namespaced identifiers rather than the literal English source text
    /// `Text`'s own string-interpolation key inference would otherwise require.
    private var greetingText: String {
        let key = if name.isEmpty {
            switch greetingPeriod {
            case .morning: "dashboard.greeting.morning"
            case .afternoon: "dashboard.greeting.afternoon"
            case .evening: "dashboard.greeting.evening"
            }
        } else {
            switch greetingPeriod {
            case .morning: "dashboard.greeting.morning.named"
            case .afternoon: "dashboard.greeting.afternoon.named"
            case .evening: "dashboard.greeting.evening.named"
            }
        }

        let localized = NSLocalizedString(key, comment: "")
        return name.isEmpty ? localized : String(format: localized, name)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greetingText)
                .font(Typography.h3)
                .foregroundStyle(Color("textPrimary"))
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day())
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        DashboardHeaderView(greetingPeriod: .morning, date: .now)
        DashboardHeaderView(greetingPeriod: .afternoon, date: .now, name: "Scott")
        DashboardHeaderView(greetingPeriod: .evening, date: .now)
    }
    .padding()
}
