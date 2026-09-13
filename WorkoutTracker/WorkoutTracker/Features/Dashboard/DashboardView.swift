//
//  DashboardView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct DashboardView: View {
    @State private var isPresentingRecords = false

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

            Button {
                isPresentingRecords = true
            } label: {
                Text("dashboard.recordsButton.label")
                    .font(Typography.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color("primaryBrand")))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.recordsButton")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("dashboard.title")
        .accessibilityIdentifier("screen.dashboard")
        .sheet(isPresented: $isPresentingRecords) {
            RecordsView()
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        DashboardView()
    }
    .modelContainer(container)
}
