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

    @State private var isPresentingEditor = false

    var body: some View {
        SessionSummaryView(model: SessionSummaryModel(workoutLog: log), onFinish: nil)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingEditor = true
                    } label: {
                        Text("history.detail.edit").font(Typography.body)
                    }
                    .accessibilityIdentifier("history.detail.edit")
                }
            }
            .fullScreenCover(isPresented: $isPresentingEditor) {
                WorkoutLogView(editing: log)
            }
    }
}
