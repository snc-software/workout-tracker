//
//  DayOfWeek.swift
//  WorkoutTracker
//

import Foundation

/// Raw value matches `Calendar`'s `weekday` component (1 = Sunday ... 7 = Saturday) so it interops
/// directly with `Calendar`/`Date` APIs, even though the app displays days Monday-first.
enum DayOfWeek: Int, CaseIterable, Codable, Sendable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    static let orderedMondayFirst: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    /// Today's day, per the system calendar and clock.
    static var today: DayOfWeek {
        DayOfWeek(rawValue: Calendar.current.component(.weekday, from: Date())) ?? .sunday
    }

    var id: Int {
        rawValue
    }

    /// Locale-aware three-letter day code (e.g. "MON"), per accessibility-standards.md.
    var shortLabel: String {
        Calendar.current.shortWeekdaySymbols[rawValue - 1].uppercased(with: Locale.current)
    }

    /// Locale-aware full day name (e.g. "Wednesday").
    var fullName: String {
        Calendar.current.weekdaySymbols[rawValue - 1]
    }
}
