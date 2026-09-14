//
//  ActiveWorkoutSession.swift
//  WorkoutTracker
//

import Foundation

/// App-scoped holder for the live, in-progress `WorkoutLogModel`, owned by `RootView` so the model's
/// lifetime is decoupled from whether `WorkoutLogView` is currently presented. This is what lets an
/// active workout survive being minimised into the tab-bar pill and later maximised back to full screen.
@Observable
final class ActiveWorkoutSession {
    private(set) var model: WorkoutLogModel?
    private(set) var isExpanded = false

    var isMinimizedPillVisible: Bool {
        model != nil && !isExpanded
    }

    func start(source: WorkoutLogModel.Source) {
        model = WorkoutLogModel(source: source)
        isExpanded = true
    }

    func minimize() {
        isExpanded = false
    }

    func maximize() {
        guard model != nil else { return }
        isExpanded = true
    }

    func end() {
        model = nil
        isExpanded = false
    }
}
