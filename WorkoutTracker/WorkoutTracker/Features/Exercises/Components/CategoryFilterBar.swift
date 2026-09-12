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
                FilterPill(title: String(localized: "exercises.category.all"), isSelected: selected == nil) {
                    onSelect(nil)
                }
                ForEach(categories) { category in
                    FilterPill(title: category.name, isSelected: selected == category) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .accessibilityIdentifier("exercises.categoryFilter")
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
