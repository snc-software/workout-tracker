//
//  HistoryView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

/// Pushed from the Dashboard's "View History" button, onto that tab's existing `NavigationStack` — not
/// presented as a sheet, so it gets the system back button for free.
struct HistoryView: View {
    @Query private var logs: [WorkoutLog]
    @State private var model = HistoryModel()

    var body: some View {
        let completed = model.completedWorkouts(from: logs)

        Group {
            if completed.isEmpty {
                VStack(spacing: 12) {
                    Iconoir.clockRotateRight.asImage
                        .font(.system(size: 40))
                        .foregroundStyle(Color("textSecondary"))
                        .accessibilityHidden(true)
                    Text("history.empty.title")
                        .font(Typography.h2)
                        .foregroundStyle(Color("textPrimary"))
                    Text("history.empty.subtitle")
                        .font(Typography.body)
                        .foregroundStyle(Color("textSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("appBackground"))
            } else {
                List(completed) { log in
                    NavigationLink {
                        HistoryDetailView(log: log)
                    } label: {
                        HistoryRow(log: log)
                    }
                }
                .listStyle(.plain)
                .background(Color("appBackground"))
            }
        }
        .navigationTitle("history.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.history")
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        HistoryView()
    }
    .modelContainer(container)
}
