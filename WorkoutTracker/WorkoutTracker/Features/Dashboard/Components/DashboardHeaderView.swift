//
//  DashboardHeaderView.swift
//  WorkoutTracker
//

import SwiftUI

struct DashboardHeaderView: View {
    let greetingPeriod: GreetingPeriod
    let date: Date

    private var greetingKey: LocalizedStringKey {
        switch greetingPeriod {
        case .morning:
            "dashboard.greeting.morning"
        case .afternoon:
            "dashboard.greeting.afternoon"
        case .evening:
            "dashboard.greeting.evening"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(greetingKey)
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
        DashboardHeaderView(greetingPeriod: .afternoon, date: .now)
        DashboardHeaderView(greetingPeriod: .evening, date: .now)
    }
    .padding()
}
