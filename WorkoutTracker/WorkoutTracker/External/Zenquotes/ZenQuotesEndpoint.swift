//
//  ZenQuotesEndpoint.swift
//  WorkoutTracker
//

import Foundation

nonisolated enum ZenQuotesEndpoint: Endpoint {
    case randomQuote

    var baseURL: URL {
        // Force-unwrap is safe: this is a fixed, well-formed literal, not derived from external input.
        URL(string: "https://zenquotes.io")!
    }

    var path: String {
        switch self {
        case .randomQuote:
            "/api/random"
        }
    }

    var method: String {
        switch self {
        case .randomQuote:
            "GET"
        }
    }
}
