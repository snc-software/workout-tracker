//
//  DashboardModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class DashboardModel {
    func greetingPeriod(at date: Date = .now, calendar: Calendar = .current) -> GreetingPeriod {
        GreetingPeriod(hour: calendar.component(.hour, from: date))
    }

    func stats(
        from workoutLogs: [WorkoutLog],
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> DashboardStats {
        DashboardStats(workoutLogs: workoutLogs, referenceDate: referenceDate, calendar: calendar)
    }
}
