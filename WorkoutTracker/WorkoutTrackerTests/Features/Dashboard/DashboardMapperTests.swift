//
//  DashboardMapperTests.swift
//  WorkoutTrackerTests
//

import Foundation
import Testing
@testable import WorkoutTracker

@MainActor
struct DashboardMapperTests {
    private let benchPress = Exercise(name: "Bench Press")

    /// Wednesday 2026-01-14, so its Mon–Sun week runs 2026-01-12...2026-01-18.
    private let referenceDate = Date(timeIntervalSince1970: 1_768_392_000)

    private func makeFinishedLog(finishedAt: Date, weightKg: Double = 100, reps: Int = 5) -> WorkoutLog {
        WorkoutLog(
            startedAt: finishedAt,
            finishedAt: finishedAt,
            exercises: [
                WorkoutLogExercise(
                    exercise: benchPress,
                    order: 0,
                    sets: [WorkoutSetLog(order: 0, weightKg: weightKg, reps: reps)]
                )
            ]
        )
    }

    private func daysFromReference(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
    }

    @Test func workoutsThisWeekCountsOnlyFinishedLogsFallingInTheReferenceDatesMondayToSundayWeek() {
        let logs = [
            makeFinishedLog(finishedAt: daysFromReference(-2)), // Monday of the reference week
            makeFinishedLog(finishedAt: daysFromReference(0)), // Wednesday of the reference week
            makeFinishedLog(finishedAt: daysFromReference(4)) // Sunday of the reference week
        ]

        let stats = DashboardStats(workoutLogs: logs, referenceDate: referenceDate)

        #expect(stats.workoutsThisWeek == 3)
    }

    @Test func workoutsThisWeekExcludesLogsWithNoFinishedDate() {
        let inProgress = WorkoutLog(startedAt: referenceDate, finishedAt: nil)

        let stats = DashboardStats(workoutLogs: [inProgress], referenceDate: referenceDate)

        #expect(stats.workoutsThisWeek == 0)
    }

    @Test func workoutsThisWeekExcludesLogsFinishedInAnAdjacentWeek() {
        let logs = [
            makeFinishedLog(finishedAt: daysFromReference(-3)), // previous Sunday
            makeFinishedLog(finishedAt: daysFromReference(5)) // next Monday
        ]

        let stats = DashboardStats(workoutLogs: logs, referenceDate: referenceDate)

        #expect(stats.workoutsThisWeek == 0)
    }

    @Test func weightLiftedThisWeekSumsWeightKgTimesRepsAcrossAllSetsInThisWeeksFinishedLogsOnly() {
        let logs = [
            makeFinishedLog(finishedAt: daysFromReference(0), weightKg: 100, reps: 8),
            makeFinishedLog(finishedAt: daysFromReference(1), weightKg: 50, reps: 10),
            makeFinishedLog(finishedAt: daysFromReference(-3), weightKg: 999, reps: 99) // adjacent week
        ]

        let stats = DashboardStats(workoutLogs: logs, referenceDate: referenceDate)

        #expect(stats.weightLiftedThisWeekKg == 100 * 8 + 50 * 10)
    }

    @Test func consecutiveWeekStreakCountsBackFromTheReferenceWeekAndStopsAtTheFirstWeekWithNoFinishedLog() {
        let logs = [
            makeFinishedLog(finishedAt: daysFromReference(0)), // this week
            makeFinishedLog(finishedAt: daysFromReference(-7)), // last week
            makeFinishedLog(finishedAt: daysFromReference(-14)), // week before that
            makeFinishedLog(finishedAt: daysFromReference(-28)) // a gap week earlier — must not count
        ]

        let stats = DashboardStats(workoutLogs: logs, referenceDate: referenceDate)

        #expect(stats.consecutiveWeekStreak == 3)
    }

    @Test func consecutiveWeekStreakIsZeroWhenTheReferenceWeekHasNoFinishedLogEvenIfEarlierWeeksDid() {
        let logs = [
            makeFinishedLog(finishedAt: daysFromReference(-7)),
            makeFinishedLog(finishedAt: daysFromReference(-14))
        ]

        let stats = DashboardStats(workoutLogs: logs, referenceDate: referenceDate)

        #expect(stats.consecutiveWeekStreak == 0)
    }

    @Test func emptyWorkoutLogsProduceAllZeroStats() {
        let stats = DashboardStats(workoutLogs: [], referenceDate: referenceDate)

        #expect(stats.workoutsThisWeek == 0)
        #expect(stats.weightLiftedThisWeekKg == 0)
        #expect(stats.consecutiveWeekStreak == 0)
    }

    @Test func quoteInitFromDTOMapsTextAndAuthor() {
        let dto = ZenQuoteDTO(text: "Acknowledging the good that you already have.", author: "Eckhart Tolle")

        let quote = Quote(dto: dto)

        #expect(quote.text == "Acknowledging the good that you already have.")
        #expect(quote.author == "Eckhart Tolle")
    }

    @Test func quoteInitFromRecordMapsTextAndAuthor() {
        let record = QuoteOfTheDayRecord(date: referenceDate, text: "Stay hungry, stay foolish.", author: "Steve Jobs")

        let quote = Quote(record: record)

        #expect(quote.text == "Stay hungry, stay foolish.")
        #expect(quote.author == "Steve Jobs")
    }

    @Test func quoteOfTheDayRecordInitFromDomainStoresTheGivenDate() {
        let quote = Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs")

        let record = QuoteOfTheDayRecord(domain: quote, date: referenceDate)

        #expect(record.text == quote.text)
        #expect(record.author == quote.author)
        #expect(record.date == referenceDate)
    }
}
