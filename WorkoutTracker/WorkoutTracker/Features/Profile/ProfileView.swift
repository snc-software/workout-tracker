//
//  ProfileView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: UserProfile
    @State private var model = ProfileModel()
    /// Kept separate from `profile.name` so a trailing space the user is still typing isn't stripped
    /// out from under them by `ProfileModel.updateName`'s trim before they've finished typing.
    @State private var name: String

    init(profile: UserProfile) {
        self.profile = profile
        _name = State(initialValue: profile.name)
    }

    var body: some View {
        Form {
            Section {
                TextField("profile.name.placeholder", text: $name)
                    .font(Typography.body)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("profile.name.label")
                    .accessibilityIdentifier("profile.name.field")
                    .onChange(of: name) { _, newValue in
                        model.updateName(newValue, on: profile, context: modelContext)
                    }
            } header: {
                sectionHeader("profile.name.label")
            }

            Section {
                Picker(selection: muscleMapGenderBinding) {
                    ForEach(MuscleMapGenderOption.allCases) { option in
                        Text(option.displayNameKey).tag(option)
                    }
                } label: {
                    Text("profile.muscleMapGender.label")
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("profile.muscleMapGender.picker")

                MuscleMapPicker(
                    allMuscles: [],
                    primaryMuscles: [],
                    secondaryMuscles: [],
                    gender: profile.muscleMapGender.rawValue
                )
                .frame(height: 220)
                .listRowSeparator(.hidden)
            } header: {
                sectionHeader("profile.muscleMapGender.label")
            }

            Section {
                Picker(selection: themeBinding) {
                    ForEach(ThemePreference.allCases) { theme in
                        Text(theme.displayNameKey).tag(theme)
                    }
                } label: {
                    Text("profile.theme.label")
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("profile.theme.picker")
            } header: {
                sectionHeader("profile.theme.label")
            }

            Section {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76))], spacing: 16) {
                    ForEach(AppIconCatalog.availableOptions()) { option in
                        appIconOption(option)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                sectionHeader("profile.appIcon.label")
            }
        }
        .navigationTitle("profile.title")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("screen.profile")
    }

    private var muscleMapGenderBinding: Binding<MuscleMapGenderOption> {
        Binding(
            get: { profile.muscleMapGender },
            set: { model.updateMuscleMapGender($0, on: profile, context: modelContext) }
        )
    }

    private var themeBinding: Binding<ThemePreference> {
        Binding(
            get: { profile.theme },
            set: { model.updateTheme($0, on: profile, context: modelContext) }
        )
    }

    private func appIconOption(_ option: AppIconOption) -> some View {
        let isSelected = profile.appIconName == option.id

        return Button {
            Task {
                await model.updateAppIcon(option, on: profile, context: modelContext)
            }
        } label: {
            VStack(spacing: 8) {
                appIconThumbnail(for: option)

                Text(option.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(Color("textPrimary"))
                    .lineLimit(1)

                (isSelected ? Iconoir.checkCircle : Iconoir.circle).asImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isSelected ? Color("primaryBrand") : Color("textSecondary"))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("profile.appIcon.option.\(option.id ?? "default")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func appIconThumbnail(for option: AppIconOption) -> some View {
        let cornerRadius: CGFloat = 13

        if let uiImage = UIImage(named: previewAssetName(for: option)) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color("border").opacity(0.15))
                .frame(width: 60, height: 60)
        }
    }

    /// Alternate icons in `CFBundleAlternateIcons` aren't retrievable via `UIImage(named:)` — only the
    /// loose files Xcode flattens for the *primary* icon are. So the default option's thumbnail comes
    /// from `CFBundleIconFiles`, and each alternate needs its own `<name>-Preview` regular image asset
    /// (a plain copy of the icon artwork) alongside its `.appiconset` for its thumbnail to render.
    private func previewAssetName(for option: AppIconOption) -> String {
        guard let id = option.id else {
            let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any]
            let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
            let files = primary?["CFBundleIconFiles"] as? [String]
            return files?.last ?? "AppIcon"
        }
        return "\(id)-Preview"
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(Typography.caption)
            .foregroundStyle(Color("textSecondary"))
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    UserProfileSeeder.seedIfNeeded(context: container.mainContext)
    let profile = (try? container.mainContext.fetch(FetchDescriptor<UserProfile>()))?.first ?? UserProfile()

    return NavigationStack {
        ProfileView(profile: profile)
    }
    .modelContainer(container)
}
