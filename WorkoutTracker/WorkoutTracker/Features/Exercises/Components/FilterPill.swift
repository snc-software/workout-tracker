//
//  FilterPill.swift
//  WorkoutTracker
//

import SwiftUI

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(isSelected ? Color("primaryBrand") : Color("textSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(isSelected ? Color("primarySubtleBg") : Color("surface")))
                .overlay(Capsule().stroke(isSelected ? Color("primaryBrand") : Color("border"), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("exercises.categoryFilter.\(title)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    HStack {
        FilterPill(title: "All", isSelected: true, action: {})
        FilterPill(title: "Back", isSelected: false, action: {})
    }
    .padding()
}
