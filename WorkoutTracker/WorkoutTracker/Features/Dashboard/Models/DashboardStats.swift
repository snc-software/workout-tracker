//
//  DashboardStats.swift
//  WorkoutTracker
//

import Foundation

/// Aggregated "this week" figures shown on the Dashboard, derived from completed `WorkoutLog`s.
struct DashboardStats: Equatable {
    var workoutsThisWeek: Int
    var weightLiftedThisWeekKg: Double
    var consecutiveWeekStreak: Int
}
