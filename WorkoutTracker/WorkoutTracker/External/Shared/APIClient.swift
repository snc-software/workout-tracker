//
//  APIClient.swift
//  WorkoutTracker
//

import Foundation

/// Thin, stateless wrapper around `URLSession` exposing a single generic request mechanism, shared by
/// every `External/<Integration>` client (see networking-standards.md). Adding a call means adding an
/// `Endpoint` value, not a bespoke client method.
nonisolated struct APIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let requestURL = endpoint.baseURL.appending(path: endpoint.path)
        guard var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else {
            throw APIError.transport(URLError(.badURL))
        }
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else {
            throw APIError.transport(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        for (field, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.transport(URLError(.badServerResponse))
        }
        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
