//
//  ScheduleView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct ScheduleView: View {
    var body: some View {
        VStack(spacing: 12) {
            Iconoir.calendar.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("schedule.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("schedule.placeholder")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("schedule.title")
        .accessibilityIdentifier("screen.schedule")
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
    }
}
