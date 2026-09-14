//
//  DashboardModelTests.swift
//  WorkoutTrackerTests
//

import Foundation
import SwiftData
import Testing
@testable import WorkoutTracker

@MainActor
struct DashboardModelTests {
    private struct FakeZenQuotesClient: ZenQuotesFetching {
        let result: Result<ZenQuoteDTO, Error>

        func fetchRandomQuote() async throws -> ZenQuoteDTO {
            try result.get()
        }
    }

    private struct FetchFailed: Error {}

    /// Wednesday 2026-01-14.
    private let referenceDate = Date(timeIntervalSince1970: 1_768_392_000)

    @Test func loadQuoteOfTheDayReturnsCachedQuoteWithoutCallingTheClientWhenARecordExistsForToday() async {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let today = Calendar.current.startOfDay(for: referenceDate)
        context.insert(QuoteOfTheDayRecord(date: today, text: "Cached quote.", author: "Cached Author"))
        try? context.save()

        // Throwing proves the client is never called on a cache hit.
        let model = DashboardModel(zenQuotesClient: FakeZenQuotesClient(result: .failure(FetchFailed())))

        await model.loadQuoteOfTheDay(context: context, referenceDate: referenceDate)

        #expect(model.quoteOfTheDayState == .loaded(Quote(text: "Cached quote.", author: "Cached Author")))
    }

    @Test func loadQuoteOfTheDayFetchesAndPersistsANewRecordWhenNoneExists() async throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let dto = ZenQuoteDTO(text: "Fetched quote.", author: "Fetched Author")
        let model = DashboardModel(zenQuotesClient: FakeZenQuotesClient(result: .success(dto)))

        await model.loadQuoteOfTheDay(context: context, referenceDate: referenceDate)

        #expect(model.quoteOfTheDayState == .loaded(Quote(text: "Fetched quote.", author: "Fetched Author")))

        let records = try context.fetch(FetchDescriptor<QuoteOfTheDayRecord>())
        #expect(records.count == 1)
        #expect(records.first?.text == "Fetched quote.")
        #expect(records.first?.author == "Fetched Author")
        #expect(records.first?.date == Calendar.current.startOfDay(for: referenceDate))
    }

    @Test func loadQuoteOfTheDayOverwritesAStaleRecordFromAPreviousDay() async throws {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate
        context.insert(QuoteOfTheDayRecord(date: yesterday, text: "Stale quote.", author: "Stale Author"))
        try context.save()

        let dto = ZenQuoteDTO(text: "Fresh quote.", author: "Fresh Author")
        let model = DashboardModel(zenQuotesClient: FakeZenQuotesClient(result: .success(dto)))

        await model.loadQuoteOfTheDay(context: context, referenceDate: referenceDate)

        #expect(model.quoteOfTheDayState == .loaded(Quote(text: "Fresh quote.", author: "Fresh Author")))

        let records = try context.fetch(FetchDescriptor<QuoteOfTheDayRecord>())
        #expect(records.count == 1)
        #expect(records.first?.text == "Fresh quote.")
        #expect(records.first?.date == Calendar.current.startOfDay(for: referenceDate))
    }

    @Test func loadQuoteOfTheDaySetsFailedStateWhenTheClientThrows() async {
        let context = ModelContext(PersistenceController.makeContainer(inMemory: true))
        let model = DashboardModel(zenQuotesClient: FakeZenQuotesClient(result: .failure(FetchFailed())))

        await model.loadQuoteOfTheDay(context: context, referenceDate: referenceDate)

        #expect(model.quoteOfTheDayState == .failed)
    }
}
