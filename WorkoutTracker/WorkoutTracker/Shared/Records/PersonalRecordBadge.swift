//
//  PersonalRecordBadge.swift
//  WorkoutTracker
//

import Foundation
import Iconoir
import SwiftUI

struct PersonalRecordBadge: View {
    let weightKg: Double

    private var formattedWeight: String {
        Measurement(value: weightKg, unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }

    var body: some View {
        HStack(spacing: 4) {
            Iconoir.starSolid.asImage
                .resizable()
                .scaledToFit()
                .frame(width: 13, height: 13)

            Text(formattedWeight)
                .font(.custom("Manrope-Bold", size: 14))
        }
        .foregroundStyle(Color("warningForeground"))
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Capsule().fill(Color("warningBackground")))
        .overlay(Capsule().stroke(Color("warningBorder"), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(format: NSLocalizedString("records.badge.accessibilityLabel", comment: ""), formattedWeight)
        )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        PersonalRecordBadge(weightKg: 82.5)
        PersonalRecordBadge(weightKg: 52)
    }
    .padding()
}
