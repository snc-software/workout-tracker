//
//  MuscleChip.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct MuscleChip: View {
    let muscle: Muscle
    let color: Color
    let removeAccessibilityLabel: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(muscle.displayName)
                .font(Typography.caption)
                .foregroundStyle(color)

            Button(action: onRemove) {
                Iconoir.xmark.asImage
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
            }
            .accessibilityLabel(removeAccessibilityLabel)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .frame(minHeight: 44)
        .background(Capsule().fill(color.opacity(0.12)))
        .overlay(Capsule().stroke(color, lineWidth: 1))
    }
}

struct MuscleChipAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Iconoir.plus.asImage
                    .font(.system(size: 11, weight: .semibold))
                Text("exercises.editor.add")
                    .font(Typography.caption)
            }
            .foregroundStyle(Color("textSecondary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .frame(minHeight: 44)
            .overlay(
                Capsule().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(Color("border"))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            MuscleChip(
                muscle: Muscle(name: "Pectoralis major", displayName: "Chest", isFront: true),
                color: Color("primaryBrand"),
                removeAccessibilityLabel: "Remove Chest from primary muscles",
                onRemove: {}
            )
            MuscleChipAddButton(action: {})
        }
    }
    .padding()
}
