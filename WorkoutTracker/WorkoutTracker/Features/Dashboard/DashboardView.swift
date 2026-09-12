//
//  DashboardView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Iconoir.homeSimple.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("dashboard.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("dashboard.placeholder")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("dashboard.title")
        .accessibilityIdentifier("screen.dashboard")
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
