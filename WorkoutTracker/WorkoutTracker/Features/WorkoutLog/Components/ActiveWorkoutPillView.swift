//
//  ActiveWorkoutPillView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

/// The minimised representation of a live `WorkoutLogModel`, shown above the tab bar on every screen via
/// `RootView`'s `tabViewBottomAccessory`. Forces `.colorScheme(.dark)` so it reads as a fixed dark
/// "mini-player" style bar regardless of the app's own light/dark setting, reusing the existing
/// `surface`/`textPrimary`/`textSecondary`/`primaryBrand` tokens rather than introducing one-off colours.
struct ActiveWorkoutPillView: View {
    let model: WorkoutLogModel
    let onTap: () -> Void

    /// There's no "current exercise" concept in `WorkoutLogModel` (it logs a whole workout's worth of
    /// exercises at once, not one at a time), so this shows the workout's own name and only falls back to
    /// its first exercise when the session has no name of its own (a custom session with nothing added
    /// yet still falls back further to the generic "Custom Workout" title).
    private var primaryText: String {
        model.name ?? model.entries.first?.exercise.name ?? String(localized: "workoutLog.custom.title")
    }

    private var accessibilityLabel: String {
        String(format: NSLocalizedString("activeWorkoutPill.accessibilityLabel", comment: ""), primaryText)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                iconBadge

                Text(primaryText)
                    .font(Typography.body)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                    .lineLimit(1)

                Spacer(minLength: 8)

                elapsedTimeLabel

                Iconoir.navArrowUp.asImage
                    .foregroundStyle(Color("textPrimary"))
                    .accessibilityHidden(true)
            }
            // `tabViewBottomAccessory` imposes its own fixed collapsed height on the accessory bar and
            // compresses this content to fit rather than honouring extra padding — confirmed by measuring
            // the actual rendered height against what was requested. 8pt (32pt badge + 8pt top/bottom) is
            // what that height actually allows, so this matches what real usage renders instead of
            // requesting more than the system will ever give it (which the isolated preview, having no
            // such constraint, would render as if it were).
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .colorScheme(.dark)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(elapsedAccessibilityValue)
        .accessibilityIdentifier("activeWorkoutPill")
    }

    /// Sized and coloured to match the "Active Workout Bar" design reference exactly: a 32pt circle
    /// filled with `primaryBrand`'s dark swatch (inherited from the pill's forced `.colorScheme(.dark)`,
    /// same as the reference's `#EC407A`) behind a white icon.
    /// Rasterised up front rather than drawn as a live `Circle().fill(...)`: `tabViewBottomAccessory`'s
    /// Liquid Glass container silently dims and desaturates any opaque shape fill placed inside it
    /// (confirmed by sampling actual pixel output — even a literal, fully-saturated system colour comes
    /// out roughly halved), but a pre-rendered bitmap image isn't run through that treatment.
    private var iconBadge: some View {
        Image(uiImage: Self.badgeImage)
            .accessibilityHidden(true)
    }

    @MainActor
    private static let badgeImage: UIImage = {
        let content = ZStack {
            Circle().fill(Color("primaryBrand"))
            Iconoir.fireFlame.asImage
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
        }
        .frame(width: 32, height: 32)
        .environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }()

    private var elapsedTimeLabel: some View {
        TimelineView(.periodic(from: model.startedAt, by: 1)) { context in
            Text(elapsedText(at: context.date))
                .font(Typography.bodyMono)
                .foregroundStyle(Color("textPrimary"))
        }
    }

    private var elapsedAccessibilityValue: String {
        String(format: NSLocalizedString("workoutLog.elapsed.label", comment: ""), elapsedText(at: .now))
    }

    private func elapsedText(at date: Date) -> String {
        let elapsedSeconds = max(date.timeIntervalSince(model.startedAt), 0)
        return Duration.seconds(elapsedSeconds).formatted(.time(pattern: .minuteSecond))
    }
}

#Preview {
    ActiveWorkoutPillView(
        model: WorkoutLogModel(source: .custom, startedAt: Date().addingTimeInterval(-759)),
        onTap: {}
    )
    .padding()
    .background(Color("appBackground"))
}
