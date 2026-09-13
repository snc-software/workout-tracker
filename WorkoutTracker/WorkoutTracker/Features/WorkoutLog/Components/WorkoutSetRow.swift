//
//  WorkoutSetRow.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct WorkoutSetRow: View {
    @Bindable var set: WorkoutSetLog
    let onRemove: () -> Void

    @State private var weightText: String
    @State private var repsText: String

    init(set: WorkoutSetLog, onRemove: @escaping () -> Void) {
        self.set = set
        self.onRemove = onRemove
        _weightText = State(initialValue: Self.format(set.weightKg))
        _repsText = State(initialValue: String(set.reps))
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(set.order + 1)")
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
                .frame(width: 20, alignment: .leading)
                .accessibilityHidden(true)

            TextField("", text: $repsText)
                .keyboardType(.numberPad)
                .font(Typography.body)
                .onChange(of: repsText) { _, newValue in
                    if let parsed = Int(newValue) {
                        set.reps = parsed
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("workoutLog.set.reps.label")
                .accessibilityIdentifier("workoutLog.set.\(set.id).reps")

            TextField("", text: $weightText)
                .keyboardType(.decimalPad)
                .font(Typography.body)
                .onChange(of: weightText) { _, newValue in
                    if let parsed = Double(newValue) {
                        set.weightKg = parsed
                    }
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("workoutLog.set.weight.label")
                .accessibilityIdentifier("workoutLog.set.\(set.id).weight")

            Button(action: onRemove) {
                Iconoir.trash.asImage
                    .foregroundStyle(Color("textSecondary"))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("workoutLog.set.remove")
            .accessibilityIdentifier("workoutLog.set.\(set.id).remove")
        }
        .accessibilityElement(children: .contain)
    }

    private static func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
    }
}

#Preview {
    WorkoutSetRow(set: WorkoutSetLog(order: 0, weightKg: 80, reps: 8), onRemove: {})
        .padding()
}
