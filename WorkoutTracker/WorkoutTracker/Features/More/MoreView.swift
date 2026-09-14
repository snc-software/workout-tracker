//
//  MoreView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

struct MoreView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        List {
            Section {
                if let profile = profiles.first {
                    NavigationLink {
                        ProfileView(profile: profile)
                    } label: {
                        Text("more.profile.label").font(Typography.body)
                    }
                    .accessibilityIdentifier("more.profile.row")
                }
            } header: {
                Label {
                    Text("more.accountManagement.label").font(Typography.h5)
                } icon: {
                    Iconoir.profileCircle.asImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                }
            }
        }
        .listStyle(.plain)
        .background(Color("appBackground"))
        .accessibilityIdentifier("screen.more")
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    UserProfileSeeder.seedIfNeeded(context: container.mainContext)

    return NavigationStack {
        MoreView()
    }
    .modelContainer(container)
}
