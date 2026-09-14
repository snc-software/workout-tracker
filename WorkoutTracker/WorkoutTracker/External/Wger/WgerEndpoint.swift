//
//  WgerEndpoint.swift
//  WorkoutTracker
//

import Foundation

nonisolated enum WgerEndpoint: Endpoint {
    case searchExercises(query: String)

    var baseURL: URL {
        // Force-unwrap is safe: this is a fixed, well-formed literal, not derived from external input.
        URL(string: "https://wger.de")!
    }

    var path: String {
        switch self {
        case .searchExercises:
            "/api/v2/exerciseinfo/"
        }
    }

    var method: String {
        switch self {
        case .searchExercises:
            "GET"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .searchExercises(query):
            [
                URLQueryItem(name: "name__search", value: query),
                URLQueryItem(name: "language", value: "2"),
                URLQueryItem(name: "limit", value: "20")
            ]
        }
    }
}
