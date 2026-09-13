//
//  QuickNavCard.swift
//  WorkoutTracker
//
//  A tappable-card label: the icon+title content only. The caller supplies the actual tap behaviour
//  (NavigationLink or Button) so this stays a plain label view, reusable in either.
//

import Iconoir
import SwiftUI

struct QuickNavCard: View {
    let icon: Iconoir
    let label: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            icon.asImage
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text(label)
                .font(Typography.body)
                .fontWeight(.bold)
                .foregroundStyle(Color("textPrimary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }
}

#Preview {
    HStack(spacing: 10) {
        QuickNavCard(icon: .clockRotateRight, label: "dashboard.historyButton.label")
        QuickNavCard(icon: .trophy, label: "dashboard.recordsButton.label")
    }
    .padding()
}
