//
//  ScheduleModelTests.swift
//  WorkoutTrackerTests
//

import Testing
@testable import WorkoutTracker

@MainActor
struct ScheduleModelTests {
    private let benchPress = Exercise(name: "Bench Press")

    @Test func workoutForDayReturnsTheMatchingWorkoutOrNilWhenNoneScheduled() {
        let model = ScheduleModel()
        let monday = ScheduledWorkout(dayOfWeek: .monday)
        let workouts = [monday]

        #expect(model.workout(for: .monday, in: workouts) === monday)
        #expect(model.workout(for: .tuesday, in: workouts) == nil)
    }

    @Test func exerciseCountReflectsTheNumberOfScheduledExercises() {
        let model = ScheduleModel()
        let workout = ScheduledWorkout(dayOfWeek: .monday)
        workout.exercises = [
            ScheduledWorkoutExercise(exercise: benchPress, order: 0),
            ScheduledWorkoutExercise(exercise: benchPress, order: 1)
        ]

        #expect(model.exerciseCount(for: workout) == 2)
    }

    @Test func scheduledDaysReturnsOnlyDaysWithAWorkoutInMondayFirstOrder() {
        let model = ScheduleModel()
        let workouts = [
            ScheduledWorkout(dayOfWeek: .friday),
            ScheduledWorkout(dayOfWeek: .monday),
            ScheduledWorkout(dayOfWeek: .wednesday)
        ]

        #expect(model.scheduledDays(from: workouts) == [.monday, .wednesday, .friday])
    }
}
