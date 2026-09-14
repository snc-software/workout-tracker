//
//  UserProfile.swift
//  WorkoutTracker
//

import Foundation
import SwiftData

/// A single row of on-device user preferences (see the issue's acceptance criteria). Only one row is
/// ever kept, following the same singleton shape as `QuoteOfTheDayRecord`.
@Model
final class UserProfile {
    @Attribute(.unique) var id: String
    var name: String
    var muscleMapGenderRawValue: String
    var themeRawValue: String
    /// `nil` selects the primary/default app icon; otherwise the name of an alternate icon in
    /// `AppIconCatalog`, passed straight through to `UIApplication.setAlternateIconName`.
    var appIconName: String?

    init(
        id: String = "current",
        name: String = "",
        muscleMapGenderRawValue: String = MuscleMapGenderOption.male.rawValue,
        themeRawValue: String = ThemePreference.system.rawValue,
        appIconName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.muscleMapGenderRawValue = muscleMapGenderRawValue
        self.themeRawValue = themeRawValue
        self.appIconName = appIconName
    }

    var muscleMapGender: MuscleMapGenderOption {
        get { MuscleMapGenderOption(rawValue: muscleMapGenderRawValue) ?? .male }
        set { muscleMapGenderRawValue = newValue.rawValue }
    }

    var theme: ThemePreference {
        get { ThemePreference(rawValue: themeRawValue) ?? .system }
        set { themeRawValue = newValue.rawValue }
    }
}
