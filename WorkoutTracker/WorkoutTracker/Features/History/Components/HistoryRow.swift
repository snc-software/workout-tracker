//
//  HistoryRow.swift
//  WorkoutTracker
//

import SwiftUI

struct HistoryRow: View {
    let log: WorkoutLog

    var body: some View {
        HStack {
            Text(log.displayTitle)
                .font(Typography.body)
                .foregroundStyle(Color("textPrimary"))

            Spacer()

            if let finishedAt = log.finishedAt {
                Text(finishedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption)
                    .foregroundStyle(Color("textSecondary"))
            }
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier("history.row.\(log.id)")
    }
}
