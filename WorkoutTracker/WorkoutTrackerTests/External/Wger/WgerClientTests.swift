//
//  WgerClientTests.swift
//  WorkoutTrackerTests
//
//  Only wger-specific behaviour is covered here — request/response encoding, decoding, and error
//  translation are already covered generically by APIClientTests (see networking-testing-standards.md).
//

import Foundation
import Testing
@testable import WorkoutTracker

@Suite(.serialized)
struct WgerClientTests {
    private func makeClient() -> WgerClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return WgerClient(apiClient: APIClient(session: URLSession(configuration: configuration)))
    }

    private func makeResponse() throws -> HTTPURLResponse {
        let url = WgerEndpoint.searchExercises(query: "").baseURL
        return try #require(HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil))
    }

    @Test func searchExercisesBuildsAGetRequestWithSearchLanguageAndLimit() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "wger.de") { request in
            #expect(request.url?.path == "/api/v2/exerciseinfo/")
            #expect(request.httpMethod == "GET")

            let queryItems = request.url
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
                .queryItems ?? []
            #expect(queryItems.contains(URLQueryItem(name: "name__search", value: "bench")))
            #expect(queryItems.contains(URLQueryItem(name: "language", value: "2")))
            #expect(queryItems.contains(URLQueryItem(name: "limit", value: "20")))

            return (response, Data(#"{"results":[]}"#.utf8))
        }

        _ = try await makeClient().searchExercises(matching: "bench")
    }

    @Test func searchExercisesDecodesTheResultsArray() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "wger.de") { _ in
            let body = """
            {
              "results": [
                {
                  "id": 73,
                  "category": {"id": 11, "name": "Chest"},
                  "muscles": [{"name": "Pectoralis major"}],
                  "muscles_secondary": [],
                  "translations": [{"language": 2, "name": "Bench Press"}]
                }
              ]
            }
            """
            return (response, Data(body.utf8))
        }

        let results = try await makeClient().searchExercises(matching: "bench")

        #expect(results.count == 1)
        #expect(results.first?.id == 73)
    }

    @Test func searchExercisesReturnsAnEmptyArrayForNoMatches() async throws {
        let response = try makeResponse()
        StubURLProtocol.setHandler(forHost: "wger.de") { _ in
            (response, Data(#"{"results":[]}"#.utf8))
        }

        let results = try await makeClient().searchExercises(matching: "zzzzzz")

        #expect(results.isEmpty)
    }
}
