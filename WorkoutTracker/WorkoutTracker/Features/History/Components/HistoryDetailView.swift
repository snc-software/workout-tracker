//
//  HistoryDetailView.swift
//  WorkoutTracker
//

import SwiftUI

/// Wraps `SessionSummaryView` for a `HistoryView` row. `onFinish` is `nil` — nothing to finish for a
/// workout that isn't being logged, so the system back button pushed by `HistoryView` is the only,
/// sufficient way back.
struct HistoryDetailView: View {
    let log: WorkoutLog

    var body: some View {
        SessionSummaryView(model: SessionSummaryModel(workoutLog: log), onFinish: nil)
            .navigationBarTitleDisplayMode(.inline)
    }
}
