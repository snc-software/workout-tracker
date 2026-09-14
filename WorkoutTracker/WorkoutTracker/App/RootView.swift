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
    @Query private var profiles: [UserProfile]
    @State private var selectedTab: AppTab = .dashboard
    @State private var activeWorkoutSession = ActiveWorkoutSession()

    private var theme: ThemePreference {
        profiles.first?.theme ?? .system
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.dashboard) {
                NavigationStack {
                    DashboardView()
                }
            } label: {
                Label { Text("tab.dashboard") } icon: { Iconoir.homeSimple.asImage }
                    .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("tab.dashboard")

            Tab(value: AppTab.schedule) {
                NavigationStack {
                    ScheduleView()
                }
            } label: {
                Label { Text("tab.schedule") } icon: { Iconoir.calendar.asImage }
                    .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("tab.schedule")

            Tab(value: AppTab.exercises) {
                NavigationStack {
                    ExercisesView()
                }
            } label: {
                Label { Text("tab.exercises") } icon: { Iconoir.gym.asImage }
                    .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("tab.exercises")

            Tab(value: AppTab.more) {
                NavigationStack {
                    MoreView()
                }
            } label: {
                Label { Text("tab.more") } icon: { Iconoir.menu.asImage }
                    .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("tab.more")
        }
        .tabViewBottomAccessory(isEnabled: activeWorkoutSession.isMinimizedPillVisible) {
            if let model = activeWorkoutSession.model {
                ActiveWorkoutPillView(model: model) {
                    activeWorkoutSession.maximize()
                }
            }
        }
        .tint(Color("primaryBrand"))
        .preferredColorScheme(theme.colorScheme)
        .environment(activeWorkoutSession)
        .fullScreenCover(isPresented: Binding(
            get: { activeWorkoutSession.isExpanded },
            set: { isPresented in
                if !isPresented {
                    activeWorkoutSession.minimize()
                }
            }
        )) {
            if let model = activeWorkoutSession.model {
                WorkoutLogView(
                    model: model,
                    onMinimize: { activeWorkoutSession.minimize() },
                    onEnd: { activeWorkoutSession.end() }
                )
            }
        }
    }
}

#Preview {
    let container = PersistenceController.makeContainer(inMemory: true)
    ExerciseSeeder.seedIfNeeded(context: container.mainContext)

    return RootView()
        .modelContainer(container)
}
