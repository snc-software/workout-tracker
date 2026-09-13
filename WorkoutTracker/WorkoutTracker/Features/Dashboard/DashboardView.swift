//
//  DashboardView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var scheduledWorkouts: [ScheduledWorkout]
    @State private var scheduleModel = ScheduleModel()
    @State private var isPresentingRecords = false
    @State private var isPresentingStartWorkout = false
    @State private var workoutLogSource: WorkoutLogModel.Source?

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

            if let todayWorkout = scheduleModel.workout(for: .today, in: scheduledWorkouts) {
                startTodayWorkoutPanel(for: todayWorkout)
            }

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

            Button {
                isPresentingStartWorkout = true
            } label: {
                Text("dashboard.startWorkoutButton.label")
                    .font(Typography.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color("primaryBrand")))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.startWorkoutButton")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("dashboard.title")
        .accessibilityIdentifier("screen.dashboard")
        .sheet(isPresented: $isPresentingRecords) {
            RecordsView()
        }
        .sheet(isPresented: $isPresentingStartWorkout) {
            StartWorkoutView { source in
                workoutLogSource = source
            }
        }
        .fullScreenCover(item: $workoutLogSource) { source in
            WorkoutLogView(source: source)
        }
    }

    private func startTodayWorkoutPanel(for workout: ScheduledWorkout) -> some View {
        Button {
            workoutLogSource = .scheduled(workout)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Iconoir.playSolid.asImage
                    Text("dashboard.startTodayWorkout.title")
                        .font(Typography.h4)
                }
                Text("dashboard.startTodayWorkout.subtitle")
                    .font(Typography.caption)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(Color("primaryBrand"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityIdentifier("dashboard.startTodayWorkout")
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
