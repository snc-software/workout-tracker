//
//  ZenQuoteDTO.swift
//  WorkoutTracker
//

import Foundation

/// Wire shape of one object in the ZenQuotes `/api/random` response array.
nonisolated struct ZenQuoteDTO: Decodable, Sendable {
    let text: String
    let author: String

    private enum CodingKeys: String, CodingKey {
        case text = "q"
        case author = "a"
    }
}
