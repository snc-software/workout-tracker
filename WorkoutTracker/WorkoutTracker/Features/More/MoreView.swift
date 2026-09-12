//
//  MoreView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct MoreView: View {
    var body: some View {
        VStack(spacing: 12) {
            Iconoir.menu.asImage
                .font(.system(size: 40))
                .foregroundStyle(Color("textSecondary"))
                .accessibilityHidden(true)
            Text("more.title")
                .font(Typography.h2)
                .foregroundStyle(Color("textPrimary"))
            Text("more.placeholder")
                .font(Typography.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("appBackground"))
        .navigationTitle("more.title")
        .accessibilityIdentifier("screen.more")
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}
