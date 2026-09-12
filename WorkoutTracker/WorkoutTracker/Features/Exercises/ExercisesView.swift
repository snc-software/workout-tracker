//
//  ExercisesView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct ExercisesView: View {
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query(sort: \ExerciseCategory.name) private var categories: [ExerciseCategory]
    @State private var model = ExercisesModel()

    var body: some View {
        let filtered = model.filteredExercises(from: exercises)

        VStack(spacing: 0) {
            if !categories.isEmpty {
                CategoryFilterBar(
                    categories: categories,
                    selected: model.selectedCategory,
                    onSelect: { model.selectedCategory = $0 }
                )
            }

            Group {
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Iconoir.gym.asImage
                            .font(.system(size: 40))
                            .foregroundStyle(Color("textSecondary"))
                            .accessibilityHidden(true)
                        Text("exercises.empty.title")
                            .font(Typography.h2)
                            .foregroundStyle(Color("textPrimary"))
                        Text("exercises.empty.subtitle")
                            .font(Typography.body)
                            .foregroundStyle(Color("textSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("appBackground"))
                } else {
                    List(filtered) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                    .listStyle(.plain)
                    .background(Color("appBackground"))
                }
            }
        }
        .searchable(text: $model.searchText, prompt: Text("exercises.search.prompt"))
        .navigationTitle("exercises.title")
        .accessibilityIdentifier("screen.exercises")
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        ExercisesView()
    }
    .modelContainer(container)
}
