//
//  ProfileModel.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData
import UIKit

@Observable
final class ProfileModel {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "ProfileModel")

    /// Injected so tests never touch the real `UIApplication`. `UIApplication.setAlternateIconName`
    /// has no native async variant, so the default wraps its completion handler once here.
    private let setAlternateIconName: (String?) async throws -> Void

    init(
        setAlternateIconName: @escaping (String?) async throws -> Void =
            ProfileModel.setAlternateIconNameOnSharedApplication
    ) {
        self.setAlternateIconName = setAlternateIconName
    }

    func updateName(_ name: String, on profile: UserProfile, context: ModelContext) {
        profile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        save(context: context)
    }

    func updateMuscleMapGender(_ gender: MuscleMapGenderOption, on profile: UserProfile, context: ModelContext) {
        profile.muscleMapGender = gender
        save(context: context)
    }

    func updateTheme(_ theme: ThemePreference, on profile: UserProfile, context: ModelContext) {
        profile.theme = theme
        save(context: context)
    }

    func updateAppIcon(_ option: AppIconOption, on profile: UserProfile, context: ModelContext) async {
        do {
            try await setAlternateIconName(option.id)
            profile.appIconName = option.id
            save(context: context)
        } catch {
            Self.logger.error("Failed to set alternate app icon: \(error)")
        }
    }

    private func save(context: ModelContext) {
        do {
            try context.save()
        } catch {
            Self.logger.error("Failed to save profile: \(error)")
        }
    }

    private static func setAlternateIconNameOnSharedApplication(_ name: String?) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UIApplication.shared.setAlternateIconName(name) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
