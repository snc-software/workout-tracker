//
//  DashboardMapper.swift
//  WorkoutTracker
//
//  Mapping between WorkoutLog (persistence) and DashboardStats (domain).
//

import Foundation

extension DashboardStats {
    /// Persistence → domain. `referenceDate`/`calendar` are taken as explicit parameters, not read
    /// internally, so this mapping stays pure and deterministic for a given input (see mapping-standards.md).
    init(workoutLogs: [WorkoutLog], referenceDate: Date = .now, calendar: Calendar = .current) {
        var calendar = calendar
        // Monday-first regardless of locale, matching DayOfWeek's app-wide Mon–Sun week convention.
        calendar.firstWeekday = 2

        func weekStart(for date: Date) -> Date {
            calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        }

        let finishedLogs = workoutLogs.compactMap { log -> (log: WorkoutLog, weekStart: Date)? in
            guard let finishedAt = log.finishedAt else { return nil }
            return (log, weekStart(for: finishedAt))
        }

        let referenceWeekStart = weekStart(for: referenceDate)
        let thisWeekLogs = finishedLogs.filter { $0.weekStart == referenceWeekStart }.map(\.log)

        workoutsThisWeek = thisWeekLogs.count
        weightLiftedThisWeekKg = thisWeekLogs.reduce(0.0) { total, log in
            let activeExercises = log.exercises.filter { !$0.isSkipped }
            let logVolumeKg = activeExercises.reduce(0.0) { exerciseTotal, exercise in
                exerciseTotal + exercise.sets.reduce(0.0) { $0 + $1.weightKg * Double($1.reps) }
            }
            return total + logVolumeKg
        }

        let weeksWithAWorkout = Set(finishedLogs.map(\.weekStart))
        var streak = 0
        var currentWeekStart: Date? = referenceWeekStart
        while let checkedWeekStart = currentWeekStart, weeksWithAWorkout.contains(checkedWeekStart) {
            streak += 1
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: checkedWeekStart)
        }
        consecutiveWeekStreak = streak
    }
}
