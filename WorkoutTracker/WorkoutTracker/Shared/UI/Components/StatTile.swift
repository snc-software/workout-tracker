//
//  StatTile.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct StatTile: View {
    let icon: Iconoir
    let value: String
    let label: LocalizedStringKey
    let accessibilityLabel: String
    let identifier: String
    var isBordered: Bool = true

    var body: some View {
        VStack(spacing: 4) {
            icon.asImage
                .foregroundStyle(Color("primaryBrand"))
            Text(value)
                .font(Typography.body)
                .fontWeight(.bold)
                .foregroundStyle(Color("textPrimary"))
            Text(label)
                .font(Typography.caption2)
                .foregroundStyle(Color("textSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("border"), lineWidth: isBordered ? 0.5 : 0)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(identifier)
    }
}

#Preview {
    HStack(spacing: 8) {
        StatTile(
            icon: .clock,
            value: "42 min",
            label: "sessionSummary.stat.elapsed",
            accessibilityLabel: "42 min elapsed",
            identifier: "sessionSummary.stat.elapsed"
        )
        StatTile(
            icon: .repeatIcon,
            value: "64",
            label: "sessionSummary.stat.totalReps",
            accessibilityLabel: "64 total reps",
            identifier: "sessionSummary.stat.totalReps"
        )
        StatTile(
            icon: .weight,
            value: "2,340 kg",
            label: "sessionSummary.stat.totalVolume",
            accessibilityLabel: "2,340 kg total weight",
            identifier: "sessionSummary.stat.totalVolume"
        )
    }
    .padding()
}
