//
//  SessionSummaryView.swift
//  WorkoutTracker
//

import Foundation
import Iconoir
import SwiftData
import SwiftUI

struct SessionSummaryView: View {
    @Query private var profiles: [UserProfile]

    let model: SessionSummaryModel
    /// `nil` when this screen is reached by pushing from `HistoryView` — there, the system back button
    /// is the only way out, and a "Finish" action makes no sense for a workout that isn't being logged.
    let onFinish: (() -> Void)?

    private var summary: SessionSummary {
        model.summary
    }

    private var elapsedSeconds: TimeInterval {
        max(summary.finishedAt.timeIntervalSince(summary.startedAt), 0)
    }

    private var elapsedText: String {
        Duration.seconds(elapsedSeconds).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }

    private var elapsedAccessibilityLabel: String {
        let spelled = Duration.seconds(elapsedSeconds).formatted(.units(allowed: [.hours, .minutes], width: .wide))
        return String(format: NSLocalizedString("sessionSummary.stat.elapsed.accessibilityLabel", comment: ""), spelled)
    }

    private var totalRepsText: String {
        summary.totalReps.formatted()
    }

    private var totalRepsAccessibilityLabel: String {
        String(
            format: NSLocalizedString("sessionSummary.stat.totalReps.accessibilityLabel", comment: ""),
            totalRepsText
        )
    }

    private var totalVolumeText: String {
        Measurement(value: summary.totalVolumeKg, unit: UnitMass.kilograms)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }

    private var totalVolumeAccessibilityLabel: String {
        String(
            format: NSLocalizedString("sessionSummary.stat.totalVolume.accessibilityLabel", comment: ""),
            totalVolumeText
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                muscleMapCard
                statsRow
                if !summary.newPersonalRecords.isEmpty {
                    newPersonalRecordsCard
                }
                breakdownCard
            }
            .padding()
        }
        .background(Color("appBackground"))
        .accessibilityIdentifier("screen.sessionSummary")
        .toolbar {
            if let onFinish {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onFinish()
                    } label: {
                        Text("sessionSummary.finish").font(Typography.body)
                    }
                    .accessibilityIdentifier("sessionSummary.finish")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let name = summary.name {
                Text(name)
                    .font(Typography.caption)
                    .foregroundStyle(Color("textSecondary"))
            }
            Text("sessionSummary.title")
                .font(Typography.h3)
                .foregroundStyle(Color("textPrimary"))
            Text(summary.startedAt ... max(summary.startedAt, summary.finishedAt))
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
                .accessibilityIdentifier("sessionSummary.dateRange")
        }
    }

    private var muscleMapCard: some View {
        VStack(spacing: 8) {
            MuscleMapPicker(
                allMuscles: [],
                primaryMuscles: summary.primaryMuscles,
                secondaryMuscles: summary.secondaryMuscles,
                gender: profiles.first?.muscleMapGenderRawValue ?? MuscleMapGenderOption.male.rawValue,
                onMuscleTapped: nil
            )
            .frame(height: 220)

            HStack(spacing: 16) {
                legendItem(color: Color("primaryBrand"), titleKey: "sessionSummary.legend.primary")
                legendItem(color: Color("accent"), titleKey: "sessionSummary.legend.secondary")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }

    private func legendItem(color: Color, titleKey: LocalizedStringKey) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(titleKey)
                .font(Typography.caption)
                .foregroundStyle(Color("textSecondary"))
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            StatTile(
                icon: .clock,
                value: elapsedText,
                label: "sessionSummary.stat.elapsed",
                accessibilityLabel: elapsedAccessibilityLabel,
                identifier: "sessionSummary.stat.elapsed"
            )
            StatTile(
                icon: .repeatIcon,
                value: totalRepsText,
                label: "sessionSummary.stat.totalReps",
                accessibilityLabel: totalRepsAccessibilityLabel,
                identifier: "sessionSummary.stat.totalReps"
            )
            StatTile(
                icon: .weight,
                value: totalVolumeText,
                label: "sessionSummary.stat.totalVolume",
                accessibilityLabel: totalVolumeAccessibilityLabel,
                identifier: "sessionSummary.stat.totalVolume"
            )
        }
    }

    private var newPersonalRecordsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Iconoir.trophy.asImage
                    .foregroundStyle(Color("warningForeground"))
                Text("sessionSummary.newRecords.title")
                    .font(Typography.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
            }

            ForEach(summary.newPersonalRecords) { record in
                HStack {
                    Text(record.exercise.name)
                        .font(Typography.body)
                        .foregroundStyle(Color("textPrimary"))
                    Spacer()
                    PersonalRecordBadge(weightKg: record.weightKg)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("sessionSummary.newRecord.\(record.exercise.name)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("sessionSummary.breakdown.title")
                .font(Typography.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color("textPrimary"))

            VStack(spacing: 0) {
                ForEach(Array(summary.exerciseBreakdowns.enumerated()), id: \.element.id) { index, breakdown in
                    ExerciseBreakdownRow(breakdown: breakdown)
                        .padding(.vertical, 6)

                    if index < summary.exerciseBreakdowns.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("border"), lineWidth: 0.5)
        )
    }
}

#Preview {
    let benchPress = Exercise(name: "Bench Press")
    let squat = Exercise(name: "Squat")
    benchPress.personalRecord = PersonalRecord(exercise: benchPress, weightKg: 80)

    let log = WorkoutLog(startedAt: Date().addingTimeInterval(-2520), finishedAt: Date(), name: "Push Day")
    log.exercises = [
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
            sets: [
                WorkoutSetLog(order: 0, weightKg: 120, reps: 5)
            ]
        )
    ]

    return SessionSummaryView(model: SessionSummaryModel(workoutLog: log), onFinish: {})
        .modelContainer(PersistenceController.makeContainer(inMemory: true))
}
