//
//  ZenQuotesClientTests.swift
//  WorkoutTrackerTests
//
//  Only Zenquotes-specific behaviour is covered here — request/response encoding, decoding, and error
//  translation are already covered generically by APIClientTests (see networking-testing-standards.md).
//

import Foundation
import Testing
@testable import WorkoutTracker

@Suite(.serialized)
struct ZenQuotesClientTests {
    private func makeClient() -> ZenQuotesClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return ZenQuotesClient(apiClient: APIClient(session: URLSession(configuration: configuration)))
    }

    private func makeResponse() throws -> HTTPURLResponse {
        let url = ZenQuotesEndpoint.randomQuote.baseURL
        return try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
    }

    @Test func fetchRandomQuoteBuildsAGetRequestToApiRandom() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "zenquotes.io") { request in
            #expect(request.url?.path == "/api/random")
            #expect(request.httpMethod == "GET")
            return (response, Data(#"[{"q":"Q","a":"A"}]"#.utf8))
        }

        _ = try await makeClient().fetchRandomQuote()
    }

    @Test func fetchRandomQuoteDecodesTheFirstArrayElement() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "zenquotes.io") { _ in
            let body = #"[{"q":"First","a":"Author One"},{"q":"Second","a":"Author Two"}]"#
            return (response, Data(body.utf8))
        }

        let dto = try await makeClient().fetchRandomQuote()

        #expect(dto.text == "First")
        #expect(dto.author == "Author One")
    }

    @Test func fetchRandomQuoteThrowsDecodingFailedForAnEmptyArray() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "zenquotes.io") { _ in
            (response, Data("[]".utf8))
        }

        await #expect(throws: APIError.decodingFailed) {
            _ = try await makeClient().fetchRandomQuote()
        }
    }
}
