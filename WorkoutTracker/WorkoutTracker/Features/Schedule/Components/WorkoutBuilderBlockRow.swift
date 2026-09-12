//
//  WorkoutBuilderBlockRow.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct WorkoutBuilderBlockRow: View {
    let block: WorkoutBuilderModel.Block
    let model: WorkoutBuilderModel
    let isReordering: Bool

    var body: some View {
        switch block {
        case let .exercise(entry):
            exerciseRow(entry)
        case let .superset(id, exercises):
            supersetCard(supersetID: id, exercises: exercises)
        }
    }

    private func exerciseRow(_ entry: ScheduledWorkoutExercise) -> some View {
        let isSelected = model.isSelectingForSuperset && model.selectedBlockIDs.contains(block.id)
        return HStack {
            Text(entry.exercise.name)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color("textPrimary"))
            Spacer()
            trailingControl(for: block)
        }
        .padding(12)
        .background(isSelected ? Color("primarySubtleBg") : Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color("primaryBrand") : Color("border"), lineWidth: isSelected ? 1.5 : 0.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("schedule.builder.block.exercise.\(entry.exercise.name)")
    }

    private func supersetCard(supersetID: UUID, exercises: [ScheduledWorkoutExercise]) -> some View {
        let isSelected = model.isSelectingForSuperset && model.selectedBlockIDs.contains(block.id)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Iconoir.link.asImage
                    .foregroundStyle(Color("accent"))
                Text("schedule.builder.superset.label")
                    .font(Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("accent"))
                Spacer()
                trailingControl(for: block)
            }

            ForEach(exercises) { entry in
                memberRow(entry, supersetID: supersetID, members: exercises)
            }
        }
        .padding(12)
        .background(isSelected ? Color("primarySubtleBg") : Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color("primaryBrand") : Color("accent"), lineWidth: 1.5)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("schedule.builder.block.superset")
        .swipeActions(edge: .trailing) {
            if !model.isSelectingForSuperset {
                Button {
                    model.ungroup(block)
                } label: {
                    Label {
                        Text("schedule.builder.ungroup")
                    } icon: {
                        Iconoir.link.asImage
                    }
                }
                .tint(Color("accent"))
                .accessibilityIdentifier("schedule.builder.block.\(identifierSuffix(for: block)).ungroup")
            }
        }
    }

    private func memberRow(
        _ entry: ScheduledWorkoutExercise,
        supersetID: UUID,
        members: [ScheduledWorkoutExercise]
    ) -> some View {
        let index = members.firstIndex { $0.id == entry.id }
        return HStack {
            if isReordering {
                moveControls(for: entry, index: index, supersetID: supersetID, memberCount: members.count)
            }
            Text(entry.exercise.name)
                .font(Typography.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color("textPrimary"))
            Spacer()
            if !model.isSelectingForSuperset, !isReordering {
                Button {
                    model.removeExercise(entry)
                } label: {
                    Iconoir.xmark.asImage
                        .foregroundStyle(Color("textSecondary"))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    String(
                        format: NSLocalizedString("schedule.builder.removeExercise", comment: ""),
                        entry.exercise.name
                    )
                )
                .accessibilityIdentifier("schedule.builder.block.exercise.\(entry.exercise.name).remove")
            }
        }
        .padding(.leading, 20)
    }

    /// System `chevron` symbols, not Iconoir, to read as an extension of the native reorder
    /// handle used for top-level blocks rather than a mismatched custom icon.
    private func moveControls(
        for entry: ScheduledWorkoutExercise,
        index: Int?,
        supersetID: UUID,
        memberCount: Int
    ) -> some View {
        VStack(spacing: 2) {
            Button {
                guard let index, index > 0 else { return }
                model.moveExercise(within: supersetID, fromOffsets: IndexSet(integer: index), toOffset: index - 1)
            } label: {
                Image(systemName: "chevron.up")
            }
            .disabled(index == nil || index == 0)
            .accessibilityLabel("schedule.builder.superset.member.moveUp")
            .accessibilityIdentifier("schedule.builder.block.exercise.\(entry.exercise.name).moveUp")

            Button {
                guard let index, index < memberCount - 1 else { return }
                model.moveExercise(within: supersetID, fromOffsets: IndexSet(integer: index), toOffset: index + 2)
            } label: {
                Image(systemName: "chevron.down")
            }
            .disabled(index == nil || index == memberCount - 1)
            .accessibilityLabel("schedule.builder.superset.member.moveDown")
            .accessibilityIdentifier("schedule.builder.block.exercise.\(entry.exercise.name).moveDown")
        }
        .buttonStyle(.plain)
        .font(Typography.caption)
        .foregroundStyle(Color("textSecondary"))
    }

    private func identifierSuffix(for block: WorkoutBuilderModel.Block) -> String {
        switch block {
        case let .exercise(entry):
            "exercise.\(entry.exercise.name)"
        case let .superset(id, _):
            "superset.\(id)"
        }
    }

    @ViewBuilder
    private func trailingControl(for block: WorkoutBuilderModel.Block) -> some View {
        let suffix = identifierSuffix(for: block)
        if isReordering {
            EmptyView()
        } else if model.isSelectingForSuperset {
            let isSelected = model.selectedBlockIDs.contains(block.id)
            Button {
                model.toggleSelection(block)
            } label: {
                (isSelected ? Iconoir.checkCircle : Iconoir.circle).asImage
                    .foregroundStyle(isSelected ? Color("primaryBrand") : Color("textSecondary"))
            }
            .accessibilityLabel(isSelected ? "schedule.builder.selection.selected" :
                "schedule.builder.selection.notSelected")
            .accessibilityIdentifier("schedule.builder.block.\(suffix).selection")
        } else {
            Button {
                model.removeBlock(block)
            } label: {
                Iconoir.xmark.asImage
                    .foregroundStyle(Color("textSecondary"))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("schedule.builder.removeBlock")
            .accessibilityIdentifier("schedule.builder.block.\(suffix).remove")
        }
    }
}
