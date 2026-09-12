//
//  ScheduleView.swift
//  WorkoutTracker
//

import SwiftData
import SwiftUI

struct ScheduleView: View {
    @Query private var workouts: [ScheduledWorkout]
    @State private var model = ScheduleModel()
    @State private var builderDay: DayOfWeek?

    var body: some View {
        List(DayOfWeek.orderedMondayFirst) { day in
            let workout = model.workout(for: day, in: workouts)
            ScheduleDayRow(day: day, workout: workout) {
                builderDay = day
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .listStyle(.plain)
        .background(Color("appBackground"))
        .navigationTitle("schedule.title")
        .accessibilityIdentifier("screen.schedule")
        .sheet(item: $builderDay) { day in
            WorkoutBuilderView(day: day, workout: model.workout(for: day, in: workouts))
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        ScheduleView()
    }
    .modelContainer(container)
}
