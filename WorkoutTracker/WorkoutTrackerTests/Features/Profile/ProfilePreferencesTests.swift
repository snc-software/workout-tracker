//
//  ProfilePreferencesTests.swift
//  WorkoutTrackerTests
//

import SwiftUI
import Testing
@testable import WorkoutTracker

@MainActor
struct ProfilePreferencesTests {
    @Test(arguments: [
        (ThemePreference.system, ColorScheme?.none),
        (ThemePreference.light, ColorScheme?.some(.light)),
        (ThemePreference.dark, ColorScheme?.some(.dark))
    ])
    func themeColorSchemeMapping(theme: ThemePreference, expected: ColorScheme?) {
        #expect(theme.colorScheme == expected)
    }

    @Test func appIconCatalogAlwaysIncludesTheDefaultOptionFirst() {
        let options = AppIconCatalog.availableOptions(infoDictionary: [:])

        #expect(options.count == 1)
        #expect(options.first?.id == nil)
    }

    @Test func appIconCatalogHandlesAMissingCFBundleIconsKey() {
        let options = AppIconCatalog.availableOptions(infoDictionary: ["SomeOtherKey": "value"])

        #expect(options == [AppIconOption.defaultOption])
    }

    @Test func appIconCatalogParsesAlternateIconsFromTheInfoDictionary() {
        let infoDictionary: [String: Any] = [
            "CFBundleIcons": [
                "CFBundleAlternateIcons": [
                    "AppIcon-Dark": ["CFBundleIconFiles": ["app_icon_dark"]],
                    "AppIcon-Retro": ["CFBundleIconFiles": ["app_icon_retro"]]
                ]
            ]
        ]

        let options = AppIconCatalog.availableOptions(infoDictionary: infoDictionary)

        #expect(options.count == 3)
        #expect(options.first?.id == nil)
        #expect(options.map(\.id).contains("AppIcon-Dark"))
        #expect(options.first { $0.id == "AppIcon-Dark" }?.displayName == "Dark")
        #expect(options.first { $0.id == "AppIcon-Retro" }?.displayName == "Retro")
    }
}
