//
//  Endpoint.swift
//  WorkoutTracker
//

import Foundation

/// A typed HTTP request, reusable by every `External/<Integration>` client (see networking-standards.md).
nonisolated protocol Endpoint: Sendable {
    var baseURL: URL { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

nonisolated extension Endpoint {
    var queryItems: [URLQueryItem] {
        []
    }

    var headers: [String: String] {
        [:]
    }

    var body: Data? {
        nil
    }
}
