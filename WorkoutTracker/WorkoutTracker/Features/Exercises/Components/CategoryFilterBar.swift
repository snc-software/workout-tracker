//
//  CategoryFilterBar.swift
//  WorkoutTracker
//

import SwiftUI

struct CategoryFilterBar: View {
    let categories: [ExerciseCategory]
    let selected: ExerciseCategory?
    let onSelect: (ExerciseCategory?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pill(title: String(localized: "exercises.category.all"), isSelected: selected == nil) {
                    onSelect(nil)
                }
                ForEach(categories) { category in
                    pill(title: category.name, isSelected: selected == category) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("exercises.categoryFilter")
    }

    private func pill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
    let categories = [
        ExerciseCategory(name: "Back"),
        ExerciseCategory(name: "Legs"),
        ExerciseCategory(name: "Chest")
    ]

    return CategoryFilterBar(categories: categories, selected: categories[0], onSelect: { _ in })
}
