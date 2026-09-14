//
//  QuoteOfTheDayRecord.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

/// Caches the quote fetched for the current day so repeat visits show the same quote (see the issue's
/// acceptance criteria). A single row is kept and overwritten once `date` is no longer today, rather than
/// an ever-growing history table.
@Model
final class QuoteOfTheDayRecord {
    @Attribute(.unique) var id: String
    var date: Date
    var text: String
    var author: String

    init(id: String = "current", date: Date, text: String, author: String) {
        self.id = id
        self.date = date
        self.text = text
        self.author = author
    }
}
