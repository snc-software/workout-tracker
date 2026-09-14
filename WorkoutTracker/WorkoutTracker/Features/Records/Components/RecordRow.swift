//
//  RecordRow.swift
//  WorkoutTracker
//

import SwiftUI

struct RecordRow: View {
    let record: PersonalRecord

    private var achievedText: String? {
        guard record.achievedInWorkout != nil else { return nil }
        return String(
            format: NSLocalizedString("records.achievedAt.label", comment: ""),
            record.achievedAt.formatted(date: .abbreviated, time: .shortened)
        )
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(record.exercise.name)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))
                if let achievedText {
                    Text(achievedText)
                        .font(Typography.caption)
                        .foregroundStyle(Color("textSecondary"))
                }
            }

            Spacer()

            PersonalRecordBadge(weightKg: record.weightKg)
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("record.row.\(record.exercise.name)")
    }
}
