//
//  ExercisesView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct ExercisesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Iconoir.gym.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("exercises.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("exercises.placeholder")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("exercises.title")
        .accessibilityIdentifier("screen.exercises")
    }
}

#Preview {
    NavigationStack {
        ExercisesView()
    }
}
