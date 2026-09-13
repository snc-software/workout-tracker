//
//  HistoryModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class HistoryModel {
    func completedWorkouts(from logs: [WorkoutLog]) -> [WorkoutLog] {
        logs
            .filter { $0.finishedAt != nil }
            .sorted { ($0.finishedAt ?? .distantPast) > ($1.finishedAt ?? .distantPast) }
    }
}
