//
//  ThemePreference.swift
//  WorkoutTracker
//

import SwiftUI

enum ThemePreference: String, CaseIterable, Codable, Sendable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    /// `nil` leaves the system appearance in control, matching `.preferredColorScheme(nil)`.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .system: "profile.theme.system"
        case .light: "profile.theme.light"
        case .dark: "profile.theme.dark"
        }
    }
}
