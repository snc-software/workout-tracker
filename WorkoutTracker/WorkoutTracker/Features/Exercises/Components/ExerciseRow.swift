//
//  ExerciseRow.swift
//  WorkoutTracker
//

import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))

                if let categoryName = exercise.category?.name {
                    Text(categoryName)
                        .font(Typography.caption)
                        .foregroundStyle(Color("textSecondary"))
                }
            }

            if let personalRecord = exercise.personalRecord {
                Spacer()
                PersonalRecordBadge(weightKg: personalRecord.weightKg)
            }
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("exercise.row.\(exercise.name)")
    }
}
