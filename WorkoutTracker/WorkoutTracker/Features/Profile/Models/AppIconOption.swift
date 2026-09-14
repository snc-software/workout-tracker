//
//  AppIconOption.swift
//  WorkoutTracker
//

import Foundation

/// One selectable Home Screen icon design. `id == nil` is the primary/default icon; any other value is
/// the name of an alternate icon asset, passed straight through to `UIApplication.setAlternateIconName`.
struct AppIconOption: Identifiable, Hashable, Sendable {
    let id: String?
    let displayName: String

    static let defaultOption = AppIconOption(id: nil, displayName: String(localized: "profile.appIcon.default"))
}

/// Reads the icon designs actually declared in the asset catalog, via the `CFBundleIcons`/
/// `CFBundleAlternateIcons` entries Xcode generates from every `.appiconset` when
/// `ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS` is enabled — dropping in a new `.appiconset` makes
/// it selectable with no further code change.
enum AppIconCatalog {
    static func availableOptions(infoDictionary: [String: Any] = Bundle.main.infoDictionary ?? [:]) -> [AppIconOption] {
        var options = [AppIconOption.defaultOption]

        let icons = infoDictionary["CFBundleIcons"] as? [String: Any]
        let alternates = icons?["CFBundleAlternateIcons"] as? [String: Any]

        if let alternates {
            options += alternates.keys.sorted().map { name in
                AppIconOption(id: name, displayName: displayName(forAssetName: name))
            }
        }

        return options
    }

    /// Derives a readable label from an asset-catalog name (e.g. `"AppIcon-Dark"` → `"Dark"`), so a new
    /// icon becomes available purely by naming its `.appiconset` folder — no localization entry required.
    private static func displayName(forAssetName name: String) -> String {
        var name = name
        for prefix in ["AppIcon-", "AppIcon_", "AppIcon"] where name.hasPrefix(prefix) {
            name.removeFirst(prefix.count)
            break
        }

        let spaced = name.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
        return spaced.isEmpty ? name : spaced.capitalized
    }
}
