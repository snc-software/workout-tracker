//
//  QuoteOfTheDayCard.swift
//  WorkoutTracker
//

import Iconoir
import SwiftUI

struct QuoteOfTheDayCard: View {
    let state: DashboardModel.QuoteOfTheDayState

    var body: some View {
        switch state {
        case .loading:
            let placeholderText = String(repeating: "Loading quote of the day ", count: 3)
            QuoteContent(quote: Quote(text: placeholderText, author: "Author Name"))
                .redacted(reason: .placeholder)
                .accessibilityHidden(true)
        case let .loaded(quote):
            QuoteContent(quote: quote)
        case .failed:
            EmptyView()
        }
    }
}

private struct QuoteContent: View {
    let quote: Quote

    private var accessibilityLabel: String {
        String(
            format: NSLocalizedString("dashboard.quote.accessibilityLabel", comment: ""),
            quote.text,
            quote.author
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Iconoir.quoteSolid.asImage
                .foregroundStyle(Color("primaryBrand"))

            Text(quote.text)
                .font(Typography.bodyLarge)
                .italic()
                .foregroundStyle(Color("textPrimary"))

            Text("— \(quote.author)")
                .font(Typography.h5)
                .foregroundStyle(Color("primaryBrand"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("border"), lineWidth: 0.5)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("dashboard.quoteOfTheDay")
    }
}

#Preview("Loaded") {
    QuoteOfTheDayCard(
        state: .loaded(
            Quote(
                text: "Give me six hours to chop down a tree and I will spend the first four sharpening the axe.",
                author: "Abraham Lincoln"
            )
        )
    )
    .padding()
}

#Preview("Loading") {
    QuoteOfTheDayCard(state: .loading)
        .padding()
}

#Preview("Failed") {
    QuoteOfTheDayCard(state: .failed)
        .padding()
}
