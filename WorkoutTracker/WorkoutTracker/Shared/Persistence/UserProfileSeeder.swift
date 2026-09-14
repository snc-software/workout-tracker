//
//  UserProfileSeeder.swift
//  WorkoutTracker
//

import Foundation
import os
import SwiftData

/// Ensures the one settings row `UserProfile` needs always exists, mirroring `ExerciseSeeder`'s
/// one-time, synchronous, main-actor seeding at app launch.
enum UserProfileSeeder {
    private static let logger = Logger(subsystem: "com.workouttracker", category: "UserProfileSeeder")

    static func seedIfNeeded(context: ModelContext) {
        let alreadySeeded = (try? context.fetchCount(FetchDescriptor<UserProfile>())) ?? 0
        guard alreadySeeded == 0 else { return }

        context.insert(UserProfile())

        do {
            try context.save()
        } catch {
            logger.error("Failed to seed default user profile: \(error)")
        }
    }
}
