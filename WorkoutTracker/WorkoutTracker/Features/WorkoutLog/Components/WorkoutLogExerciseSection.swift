//
//  WorkoutLogExerciseSection.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct WorkoutLogExerciseSection: View {
    let block: WorkoutLogModel.Block
    let model: WorkoutLogModel

    var body: some View {
        switch block {
        case let .exercise(entry):
            exerciseCard(entry)
        case let .superset(id, exercises):
            supersetCard(supersetID: id, exercises: exercises)
        }
    }

    private func exerciseCard(_ entry: WorkoutLogExercise) -> some View {
        let isSelected = model.isSelectingForSuperset && model.selectedBlockIDs.contains(block.id)
        return Group {
            if entry.isSkipped {
                skippedRow(for: entry, showSelection: true)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    header(for: entry, showSelection: true)
                    setsList(for: entry)
                }
            }
        }
        .padding(12)
        .background(isSelected ? Color("accentSubtleBg") : entry.isSkipped ? Color("surfaceAccent") : Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("accent") : Color("border"), lineWidth: isSelected ? 1.5 : 0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("workoutLog.exercise.\(entry.exercise.name)")
    }

    private func supersetCard(supersetID: UUID, exercises: [WorkoutLogExercise]) -> some View {
        let isSelected = model.isSelectingForSuperset && model.selectedBlockIDs.contains(block.id)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Iconoir.link.asImage
                    .foregroundStyle(Color("accent"))
                Text("workoutLog.superset.label")
                    .font(Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("accent"))
                Spacer()
                if model.isSelectingForSuperset {
                    selectionButton(isSelected: isSelected)
                }
            }

            ForEach(exercises) { entry in
                supersetMemberRow(for: entry)
            }
        }
        .padding(12)
        .background(isSelected ? Color("accentSubtleBg") : Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("accent"), lineWidth: 1.5)
        )
        .accessibilityIdentifier("workoutLog.block.superset")
        .swipeActions(edge: .trailing) {
            if !model.isSelectingForSuperset {
                Button {
                    model.ungroup(block)
                } label: {
                    Label {
                        Text("workoutLog.ungroup")
                    } icon: {
                        Iconoir.link.asImage
                    }
                }
                .tint(Color("accent"))
                .accessibilityIdentifier("workoutLog.block.\(identifierSuffix(for: block)).ungroup")
            }
        }
    }

    private func supersetMemberRow(for entry: WorkoutLogExercise) -> some View {
        Group {
            if entry.isSkipped {
                skippedRow(for: entry, showSelection: false)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    header(for: entry, showSelection: false)
                    setsList(for: entry)
                }
            }
        }
        .padding(8)
        .background(entry.isSkipped ? Color("surfaceAccent") : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(entry.isSkipped ? Color("border") : Color.clear, lineWidth: entry.isSkipped ? 0.5 : 0)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("workoutLog.exercise.\(entry.exercise.name)")
    }

    private func header(for entry: WorkoutLogExercise, showSelection: Bool) -> some View {
        HStack {
            Text(entry.exercise.name)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color("textPrimary"))

            if let record = entry.exercise.personalRecord {
                PersonalRecordBadge(weightKg: record.weightKg)
            }

            Spacer()

            if showSelection, model.isSelectingForSuperset {
                selectionButton(isSelected: model.selectedBlockIDs.contains(block.id))
            } else if !model.isSelectingForSuperset {
                skipButton(for: entry)
            }
        }
    }

    private func skippedRow(for entry: WorkoutLogExercise, showSelection: Bool) -> some View {
        HStack {
            Text(entry.exercise.name)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color("textSecondary"))

            skippedBadge

            Spacer()

            if showSelection, model.isSelectingForSuperset {
                selectionButton(isSelected: model.selectedBlockIDs.contains(block.id))
            } else if !model.isSelectingForSuperset {
                resumeButton(for: entry)
            }
        }
    }

    private var skippedBadge: some View {
        Text("workoutLog.exercise.skippedBadge")
            .font(Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .overlay(
                Capsule().stroke(Color("border"), lineWidth: 1)
            )
    }

    private func resumeButton(for entry: WorkoutLogExercise) -> some View {
        Button {
            model.toggleSkip(entry)
        } label: {
            Text("workoutLog.exercise.resume")
                .font(Typography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color("primaryBrand"))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("workoutLog.exercise.\(entry.exercise.name).skip")
    }

    /// Only rendered for a not-yet-skipped exercise — once skipped, `skippedRow` shows `resumeButton`
    /// instead, so this never needs to represent the skipped state itself.
    private func skipButton(for entry: WorkoutLogExercise) -> some View {
        Button {
            model.toggleSkip(entry)
        } label: {
            HStack(spacing: 4) {
                Iconoir.circle.asImage
                Text("workoutLog.exercise.skip")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("workoutLog.exercise.\(entry.exercise.name).skip")
    }

    private func selectionButton(isSelected: Bool) -> some View {
        Button {
            model.toggleSelection(block)
        } label: {
            (isSelected ? Iconoir.checkCircle : Iconoir.circle).asImage
                .foregroundStyle(isSelected ? Color("accent") : Color("textSecondary"))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSelected ? "workoutLog.selection.selected" : "workoutLog.selection.notSelected")
        .accessibilityIdentifier("workoutLog.block.\(identifierSuffix(for: block)).selection")
    }

    private func identifierSuffix(for block: WorkoutLogModel.Block) -> String {
        switch block {
        case let .exercise(entry):
            "exercise.\(entry.exercise.name)"
        case let .superset(id, _):
            "superset.\(id)"
        }
    }

    private func setsList(for entry: WorkoutLogExercise) -> some View {
        VStack(spacing: 8) {
            setsHeader
            ForEach(entry.sets.sorted(by: { $0.order < $1.order })) { set in
                WorkoutSetRow(set: set) {
                    model.removeSet(set, from: entry)
                }
            }
            addSetButton(for: entry)
        }
    }

    private var setsHeader: some View {
        HStack(spacing: 12) {
            Text("workoutLog.set.header.set")
                .fixedSize()
            Text("workoutLog.set.header.reps")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("workoutLog.set.header.weight")
                .frame(maxWidth: .infinity, alignment: .leading)
            Color.clear
                .frame(width: 24)
        }
        .font(Typography.caption)
        .foregroundStyle(Color("textSecondary"))
        .accessibilityHidden(true)
    }

    private func addSetButton(for entry: WorkoutLogExercise) -> some View {
        Button {
            model.addSet(to: entry)
        } label: {
            HStack {
                Iconoir.plus.asImage
                Text("workoutLog.exercise.addSet")
            }
            .font(Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color("textSecondary"))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("workoutLog.exercise.\(entry.exercise.name).addSet")
    }
}
