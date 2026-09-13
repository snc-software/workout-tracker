//
//  RecordsModel.swift
//  WorkoutTracker
//

import Foundation

@Observable
final class RecordsModel {
    func sortedRecords(from records: [PersonalRecord]) -> [PersonalRecord] {
        records.sorted { $0.exercise.name.localizedStandardCompare($1.exercise.name) == .orderedAscending }
    }
}
