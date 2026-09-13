//
//  SessionSummaryModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class SessionSummaryModel: Identifiable {
    let id = UUID()
    let summary: SessionSummary

    init(workoutLog: WorkoutLog) {
        summary = SessionSummary(workoutLog: workoutLog)
    }
}
