//
//  RootView.swift
//  WorkoutTracker
//

import Iconoir
import SwiftData
import SwiftUI

enum AppTab: Hashable {
    case dashboard
    case schedule
    case exercises
    case more
}

struct RootView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.dashboard) {
                NavigationStack {
                    DashboardView()
                }
            } label: {
                Label { Text("tab.dashboard") } icon: { Iconoir.homeSimple.asImage }
            }
            .accessibilityIdentifier("tab.dashboard")

            Tab(value: AppTab.schedule) {
                NavigationStack {
                    ScheduleView()
                }
            } label: {
                Label { Text("tab.schedule") } icon: { Iconoir.calendar.asImage }
            }
            .accessibilityIdentifier("tab.schedule")

            Tab(value: AppTab.exercises) {
                NavigationStack {
                    ExercisesView()
                }
            } label: {
                Label { Text("tab.exercises") } icon: { Iconoir.gym.asImage }
            }
            .accessibilityIdentifier("tab.exercises")

            Tab(value: AppTab.more) {
                NavigationStack {
                    MoreView()
                }
            } label: {
                Label { Text("tab.more") } icon: { Iconoir.menu.asImage }
            }
            .accessibilityIdentifier("tab.more")
        }
        .tint(Color("primaryBrand"))
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return RootView()
        .modelContainer(container)
}
