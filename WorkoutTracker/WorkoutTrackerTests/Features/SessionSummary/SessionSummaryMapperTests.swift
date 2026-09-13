//
//  SessionSummaryMapperTests.swift
//  WorkoutTrackerTests
//

import Foundation
import Testing
@testable import WorkoutTracker

@MainActor
struct SessionSummaryMapperTests {
    private let benchPress = Exercise(name: "Bench Press")
    private let squat = Exercise(name: "Squat")

    private func makeLog(exercises: [WorkoutLogExercise]) -> WorkoutLog {
        WorkoutLog(
            startedAt: Date(timeIntervalSince1970: 0),
            finishedAt: Date(timeIntervalSince1970: 1),
            exercises: exercises
        )
    }

    @Test func totalsSumRepsAndVolumeAcrossAllNonSkippedSets() {
        let log = makeLog(exercises: [
            WorkoutLogExercise(
                exercise: benchPress,
                order: 0,
                sets: [
                    WorkoutSetLog(order: 0, weightKg: 100, reps: 8),
                    WorkoutSetLog(order: 1, weightKg: 100, reps: 8)
                ]
            ),
            WorkoutLogExercise(
                exercise: squat,
                order: 1,
                sets: [WorkoutSetLog(order: 0, weightKg: 120, reps: 5)]
            )
        ])

        let summary = SessionSummary(workoutLog: log)

        #expect(summary.totalReps == 21)
        #expect(summary.totalVolumeKg == 2200)
    }

    @Test func skippedExercisesAreExcludedFromTotalsBreakdownAndMuscles() {
        let chest = Muscle(name: "chest", displayName: "Chest")
        benchPress.primaryMuscles = [chest]

        let log = makeLog(exercises: [
            WorkoutLogExercise(
                exercise: benchPress,
                order: 0,
                isSkipped: true,
                sets: [WorkoutSetLog(order: 0, weightKg: 100, reps: 8)]
            ),
            WorkoutLogExercise(
                exercise: squat,
                order: 1,
                sets: [WorkoutSetLog(order: 0, weightKg: 120, reps: 5)]
            )
        ])

        let summary = SessionSummary(workoutLog: log)

        #expect(summary.totalReps == 5)
        #expect(summary.totalVolumeKg == 600)
        #expect(summary.exerciseBreakdowns.map(\.exercise) == [squat])
        #expect(summary.primaryMuscles.isEmpty)
    }

    @Test func breakdownReportsSetCountRepsAndVolumePerExercise() throws {
        let log = makeLog(exercises: [
            WorkoutLogExercise(
                exercise: benchPress,
                order: 0,
                sets: [
                    WorkoutSetLog(order: 0, weightKg: 60, reps: 10),
                    WorkoutSetLog(order: 1, weightKg: 65, reps: 8),
                    WorkoutSetLog(order: 2, weightKg: 70, reps: 6)
                ]
            )
        ])

        let summary = SessionSummary(workoutLog: log)

        let breakdown = try #require(summary.exerciseBreakdowns.first)
        #expect(breakdown.exercise == benchPress)
        #expect(breakdown.setCount == 3)
        #expect(breakdown.totalReps == 24)
        let expectedVolumeKg = 60.0 * 10.0 + 65.0 * 8.0 + 70.0 * 6.0
        #expect(breakdown.totalVolumeKg == expectedVolumeKg)
        #expect(breakdown.sets.map(\.order) == [0, 1, 2])
        #expect(breakdown.sets.map(\.weightKg) == [60, 65, 70])
        #expect(breakdown.sets.map(\.reps) == [10, 8, 6])
    }

    @Test func aggregatedMusclesUnionsAcrossExercisesAndPrimaryTakesPrecedenceOverSecondary() {
        let chest = Muscle(name: "chest", displayName: "Chest")
        let back = Muscle(name: "back", displayName: "Back")
        let shoulders = Muscle(name: "shoulders", displayName: "Shoulders")

        benchPress.primaryMuscles = [chest]
        benchPress.secondaryMuscles = [shoulders]
        squat.primaryMuscles = [back]
        squat.secondaryMuscles = [chest]

        let log = makeLog(exercises: [
            WorkoutLogExercise(exercise: benchPress, order: 0, sets: [WorkoutSetLog(order: 0, weightKg: 60, reps: 8)]),
            WorkoutLogExercise(exercise: squat, order: 1, sets: [WorkoutSetLog(order: 0, weightKg: 100, reps: 5)])
        ])

        let summary = SessionSummary(workoutLog: log)

        #expect(Set(summary.primaryMuscles) == [chest, back])
        #expect(Set(summary.secondaryMuscles) == [shoulders])
    }

    @Test func newPersonalRecordIncludesExerciseWhoseSessionMaxBeatsItsExistingRecord() throws {
        benchPress.personalRecord = PersonalRecord(exercise: benchPress, weightKg: 80)
        let log = makeLog(exercises: [
            WorkoutLogExercise(
                exercise: benchPress,
                order: 0,
                sets: [
                    WorkoutSetLog(order: 0, weightKg: 70, reps: 8),
                    WorkoutSetLog(order: 1, weightKg: 90, reps: 3)
                ]
            )
        ])

        let summary = SessionSummary(workoutLog: log)

        let newRecord = try #require(summary.newPersonalRecords.first)
        #expect(summary.newPersonalRecords.count == 1)
        #expect(newRecord.exercise == benchPress)
        #expect(newRecord.previousWeightKg == 80)
        #expect(newRecord.weightKg == 90)
    }

    @Test func noExistingRecordAndAPositiveLoggedWeightCountsAsANewPersonalRecordWithNilPreviousWeight() throws {
        let log = makeLog(exercises: [
            WorkoutLogExercise(exercise: benchPress, order: 0, sets: [WorkoutSetLog(order: 0, weightKg: 50, reps: 10)])
        ])

        let summary = SessionSummary(workoutLog: log)

        let newRecord = try #require(summary.newPersonalRecords.first)
        #expect(summary.newPersonalRecords.count == 1)
        #expect(newRecord.previousWeightKg == nil)
        #expect(newRecord.weightKg == 50)
    }

    @Test func noNewPersonalRecordWhenSessionMaxDoesNotBeatTheExistingRecord() {
        benchPress.personalRecord = PersonalRecord(exercise: benchPress, weightKg: 100)
        let log = makeLog(exercises: [
            WorkoutLogExercise(exercise: benchPress, order: 0, sets: [WorkoutSetLog(order: 0, weightKg: 80, reps: 8)])
        ])

        let summary = SessionSummary(workoutLog: log)

        #expect(summary.newPersonalRecords.isEmpty)
    }
}
