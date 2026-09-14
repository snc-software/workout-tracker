//
//  DashboardView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var scheduledWorkouts: [ScheduledWorkout]
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var profiles: [UserProfile]
    @State private var scheduleModel = ScheduleModel()
    @State private var dashboardModel = DashboardModel()
    @State private var isPresentingStartWorkout = false
    @Environment(ActiveWorkoutSession.self) private var activeWorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DashboardHeaderView(
                    greetingPeriod: dashboardModel.greetingPeriod(),
                    date: .now,
                    name: profiles.first?.name ?? ""
                )
                DashboardStatsCard(stats: dashboardModel.stats(from: workoutLogs))
                QuoteOfTheDayCard(state: dashboardModel.quoteOfTheDayState)

                if let todayWorkout = scheduleModel.workout(for: .today, in: scheduledWorkouts) {
                    UpcomingWorkoutCard(workout: todayWorkout) {
                        activeWorkoutSession.start(source: .scheduled(todayWorkout))
                    }
                }

                quickNavRow
                startWorkoutButton
            }
            .padding()
        }
        .background(Color("appBackground"))
        .accessibilityIdentifier("screen.dashboard")
        .task {
            await dashboardModel.loadQuoteOfTheDay(context: modelContext)
        }
        .sheet(isPresented: $isPresentingStartWorkout) {
            StartWorkoutView { source in
                activeWorkoutSession.start(source: source)
            }
        }
    }

    private var quickNavRow: some View {
        HStack(spacing: 10) {
            NavigationLink {
                HistoryView()
            } label: {
                QuickNavCard(icon: .clockRotateRight, label: "dashboard.historyButton.label")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.historyButton")

            NavigationLink {
                RecordsView()
            } label: {
                QuickNavCard(icon: .trophy, label: "dashboard.recordsButton.label")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.recordsButton")
        }
    }

    private var startWorkoutButton: some View {
        Button {
            isPresentingStartWorkout = true
        } label: {
            HStack(spacing: 8) {
                Iconoir.playSolid.asImage
                Text("dashboard.startWorkoutButton.label")
                    .font(Typography.h4)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .background(Color("primaryBrand"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityIdentifier("dashboard.startWorkoutButton")
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        DashboardView()
    }
    .modelContainer(container)
    .environment(ActiveWorkoutSession())
}
