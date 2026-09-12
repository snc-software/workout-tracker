//
//  Typography.swift
//  WorkoutTracker
//
//  Font tokens over the bundled JetBrains Mono (headings) / Manrope (body) faces,
//  per resources/DESIGN SYSTEM.md. Sizes use Font.custom(_:size:relativeTo:) so they
//  still scale with Dynamic Type despite the fixed point size.
//

import SwiftUI
import UIKit

enum Typography {
    static let h1 = Font.custom("JetBrainsMono-SemiBold", size: 44, relativeTo: .largeTitle)
    static let h2 = Font.custom("JetBrainsMono-SemiBold", size: 32, relativeTo: .title)
    static let h3 = Font.custom("JetBrainsMono-SemiBold", size: 24, relativeTo: .title2)
    static let h4 = Font.custom("JetBrainsMono-SemiBold", size: 18, relativeTo: .title3)

    static let bodyLarge = Font.custom("Manrope-Regular", size: 17, relativeTo: .body)
    static let body = Font.custom("Manrope-Regular", size: 15, relativeTo: .callout)
    static let caption = Font.custom("Manrope-Regular", size: 13, relativeTo: .footnote)
    static let caption2 = Font.custom("Manrope-Regular", size: 11, relativeTo: .caption2)

    /// `.navigationTitle` has no font modifier of its own, so the heading font is applied via
    /// `UINavigationBarAppearance` once at launch rather than per-screen.
    static func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "JetBrainsMono-SemiBold", size: 34) ?? .preferredFont(forTextStyle: .largeTitle)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "JetBrainsMono-SemiBold", size: 17) ?? .preferredFont(forTextStyle: .headline)
        ]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}
