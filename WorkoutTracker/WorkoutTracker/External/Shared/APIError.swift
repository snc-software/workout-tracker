//
//  APIError.swift
//  WorkoutTracker
//

import Foundation

/// Typed transport/decoding/server failures, shared by every `External/<Integration>` client
/// (see networking-standards.md). Raw `URLError`/`DecodingError`/HTTP status MUST NOT reach feature models.
nonisolated enum APIError: Error, LocalizedError, Equatable {
    case transport(URLError)
    case decodingFailed
    case server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .transport:
            "A network error occurred."
        case .decodingFailed:
            "The server response could not be understood."
        case let .server(statusCode):
            "The server returned an error (\(statusCode))."
        }
    }
}
