//
//  APIClientTests.swift
//  WorkoutTrackerTests
//

import Foundation
import Testing
@testable import WorkoutTracker

@Suite(.serialized)
struct APIClientTests {
    private struct TestPayload: Decodable, Equatable {
        let value: String
    }

    private struct TestEndpoint: Endpoint {
        // Force-unwrap is safe: a fixed, well-formed literal, not derived from external input.
        let baseURL = URL(string: "https://example.com")!
        let path = "/thing"
        let method = "GET"
    }

    private func makeClient() -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return APIClient(session: URLSession(configuration: configuration))
    }

    private func makeResponse(url: URL, statusCode: Int) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil))
    }

    @Test func sendDecodesASuccessfulResponse() async throws {
        let response = try makeResponse(url: TestEndpoint().baseURL, statusCode: 200)
        StubURLProtocol.setHandler(forHost: "example.com") { _ in
            (response, Data(#"{"value":"hello"}"#.utf8))
        }

        let payload: TestPayload = try await makeClient().send(TestEndpoint())

        #expect(payload == TestPayload(value: "hello"))
    }

    @Test func sendThrowsServerForANon2xxStatus() async throws {
        let response = try makeResponse(url: TestEndpoint().baseURL, statusCode: 404)
        StubURLProtocol.setHandler(forHost: "example.com") { _ in
            (response, Data())
        }

        await #expect(throws: APIError.server(statusCode: 404)) {
            let _: TestPayload = try await makeClient().send(TestEndpoint())
        }
    }

    @Test func sendThrowsDecodingFailedForMalformedJSON() async throws {
        let response = try makeResponse(url: TestEndpoint().baseURL, statusCode: 200)
        StubURLProtocol.setHandler(forHost: "example.com") { _ in
            (response, Data("not json".utf8))
        }

        await #expect(throws: APIError.decodingFailed) {
            let _: TestPayload = try await makeClient().send(TestEndpoint())
        }
    }

    @Test func sendThrowsTransportForAURLError() async {
        StubURLProtocol.setHandler(forHost: "example.com") { _ in throw URLError(.notConnectedToInternet) }

        do {
            let _: TestPayload = try await makeClient().send(TestEndpoint())
            Issue.record("Expected send to throw")
        } catch let APIError.transport(underlying) {
            #expect(underlying.code == .notConnectedToInternet)
        } catch {
            Issue.record("Expected APIError.transport, got \(error)")
        }
    }
}
