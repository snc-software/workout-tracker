//
//  ScheduleModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class ScheduleModel {
    func workout(for day: DayOfWeek, in workouts: [ScheduledWorkout]) -> ScheduledWorkout? {
        workouts.first { $0.dayOfWeek == day }
    }

    func exerciseCount(for workout: ScheduledWorkout) -> Int {
        workout.exercises.count
    }

    /// Monday-first days that have a scheduled workout.
    func scheduledDays(from workouts: [ScheduledWorkout]) -> [DayOfWeek] {
        DayOfWeek.orderedMondayFirst.filter { day in workouts.contains { $0.dayOfWeek == day } }
    }
}
