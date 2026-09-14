//
//  StubURLProtocol.swift
//  WorkoutTrackerTests
//
//  Deterministic URLProtocol stub for testing APIClient/ZenQuotesClient without a live network call
//  (see networking-testing-standards.md). Handlers are keyed by request host, and each suite that uses
//  this MUST be `@Suite(.serialized)`, so two tests targeting the same host never race on the same key.
//

import Foundation

final class StubURLProtocol: URLProtocol {
    typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)

    private static let lock = NSLock()
    private nonisolated(unsafe) static var handlers: [String: Handler] = [:]

    static func setHandler(forHost host: String, _ handler: @escaping Handler) {
        lock.lock()
        handlers[host] = handler
        lock.unlock()
    }

    private static func handler(forHost host: String?) -> Handler? {
        lock.lock()
        defer { lock.unlock() }
        return handlers[host ?? ""]
    }

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler(forHost: request.url?.host) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
