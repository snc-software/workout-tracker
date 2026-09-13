//
//  GreetingPeriod.swift
//  WorkoutTracker
//

import Foundation

/// Time-of-day bucket driving the Dashboard's greeting text.
enum GreetingPeriod: Equatable {
    case morning
    case afternoon
    case evening

    init(hour: Int) {
        switch hour {
        case ..<12:
            self = .morning
        case 12 ..< 17:
            self = .afternoon
        default:
            self = .evening
        }
    }
}
