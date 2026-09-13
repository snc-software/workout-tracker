//
//  ExerciseBreakdownRow.swift
//  WorkoutTracker
//

import SwiftUI

struct ExerciseBreakdownRow: View {
    let breakdown: SessionSummary.ExerciseBreakdown

    @State private var isExpanded = false

    private var volumeText: String {
        Measurement(value: breakdown.totalVolumeKg, unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(breakdown.sets) { set in
                    setRow(set)
                }
            }
            .padding(.top, 6)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(breakdown.exercise.name)
                    .font(Typography.body)
                    .foregroundStyle(Color("textPrimary"))
                (
                    Text("^[\(breakdown.setCount) set](inflect: true) · ^[\(breakdown.totalReps) rep](inflect: true)")
                        + Text(" · \(volumeText)")
                )
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
            }
        }
        .accessibilityIdentifier("sessionSummary.breakdown.\(breakdown.exercise.name)")
    }

    private func setRow(_ set: SessionSummary.SetDetail) -> some View {
        let weightText = Measurement(value: set.weightKg, unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))

        return HStack {
            Text(String(
                format: NSLocalizedString("sessionSummary.breakdown.setIndex", comment: ""),
                (set.order + 1).formatted()
            ))
            .font(Typography.caption)
            .foregroundStyle(Color("textSecondary"))
            Spacer()
            Text("\(weightText) · ^[\(set.reps) rep](inflect: true)")
                .font(Typography.caption)
                .foregroundStyle(Color("textPrimary"))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let exercise = Exercise(name: "Bench Press")
    return ExerciseBreakdownRow(
        breakdown: SessionSummary.ExerciseBreakdown(
            exercise: exercise,
            setCount: 3,
            totalReps: 26,
            totalVolumeKg: 920,
            sets: [
                .init(order: 0, weightKg: 60, reps: 10),
                .init(order: 1, weightKg: 65, reps: 8),
                .init(order: 2, weightKg: 70, reps: 8)
            ]
        )
    )
    .padding()
}
