//
//  ZenQuotesClient.swift
//  WorkoutTracker
//

import Foundation

/// Abstraction `DashboardModel` depends on, so tests can substitute a fake without a live network call
/// (see unit-testing-standards.md).
nonisolated protocol ZenQuotesFetching: Sendable {
    func fetchRandomQuote() async throws -> ZenQuoteDTO
}

nonisolated struct ZenQuotesClient: ZenQuotesFetching {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchRandomQuote() async throws -> ZenQuoteDTO {
        let quotes: [ZenQuoteDTO] = try await apiClient.send(ZenQuotesEndpoint.randomQuote)
        guard let quote = quotes.first else {
            throw APIError.decodingFailed
        }
        return quote
    }
}
