//
//  RecordRow.swift
//  WorkoutTracker
//

import SwiftUI

struct RecordRow: View {
    let record: PersonalRecord

    var body: some View {
        HStack {
            Text(record.exercise.name)
                .font(Typography.body)
                .foregroundStyle(Color("textPrimary"))

            Spacer()

            PersonalRecordBadge(weightKg: record.weightKg)
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("record.row.\(record.exercise.name)")
    }
}
