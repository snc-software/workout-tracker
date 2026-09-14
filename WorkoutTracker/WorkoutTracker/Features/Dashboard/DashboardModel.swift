//
//  DashboardModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

@Observable
final class DashboardModel {
    enum QuoteOfTheDayState: Equatable {
        case loading
        case loaded(Quote)
        case failed
    }

    private static let logger = Logger(subsystem: "com.workouttracker", category: "DashboardModel")

    private(set) var quoteOfTheDayState = QuoteOfTheDayState.loading

    private let zenQuotesClient: any ZenQuotesFetching

    init(zenQuotesClient: any ZenQuotesFetching = ZenQuotesClient()) {
        self.zenQuotesClient = zenQuotesClient
    }

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

    /// Loads today's cached quote, or fetches and caches a new one if none is stored for today yet.
    func loadQuoteOfTheDay(
        context: ModelContext,
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) async {
        let today = calendar.startOfDay(for: referenceDate)
        let existing = try? context.fetch(FetchDescriptor<QuoteOfTheDayRecord>()).first

        if let existing, calendar.isDate(existing.date, inSameDayAs: today) {
            quoteOfTheDayState = .loaded(Quote(record: existing))
            return
        }

        do {
            let quote = try await Quote(dto: zenQuotesClient.fetchRandomQuote())

            if let existing {
                existing.date = today
                existing.text = quote.text
                existing.author = quote.author
            } else {
                context.insert(QuoteOfTheDayRecord(domain: quote, date: today))
            }
            try context.save()

            quoteOfTheDayState = .loaded(quote)
        } catch {
            Self.logger.error("Failed to load quote of the day: \(error)")
            quoteOfTheDayState = .failed
        }
    }
}
