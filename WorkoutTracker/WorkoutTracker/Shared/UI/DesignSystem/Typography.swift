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
    static let h5 = Font.custom("JetBrainsMono-SemiBold", size: 13, relativeTo: .subheadline)

    static let bodyLarge = Font.custom("Manrope-Regular", size: 17, relativeTo: .body)
    static let body = Font.custom("Manrope-Regular", size: 15, relativeTo: .callout)
    static let caption = Font.custom("Manrope-Regular", size: 13, relativeTo: .footnote)
    static let caption2 = Font.custom("Manrope-Regular", size: 11, relativeTo: .caption2)

    /// Small uppercase eyebrow labels (e.g. "THIS WEEK") — caption2's size in the heading face.
    static let overline = Font.custom("JetBrainsMono-SemiBold", size: 11, relativeTo: .caption2)

    /// Numeric displays like an elapsed-time counter — body's size in the heading (monospace) face, so
    /// digits read as prominently as a heading without the extra size jump a full heading token would add.
    static let bodyMono = Font.custom("JetBrainsMono-SemiBold", size: 15, relativeTo: .callout)

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
