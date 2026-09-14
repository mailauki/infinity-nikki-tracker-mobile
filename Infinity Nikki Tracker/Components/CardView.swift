//
//  CardView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/13/26.
//

import SwiftUI

enum CardLayout {
    case card, row
}

struct CardView: View {
    let item: any CardDisplayable
    var layout: CardLayout = .card

    private var obtained: Int { item.cardObtained }
    private var total: Int { item.cardTotal }
    private var hasUserData: Bool { item.cardHasUserData }

    var body: some View {
        switch layout {
        case .card: cardLayout
        case .row:  rowLayout
        }
    }

    private var cardLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            CardMediaView(url: item.cardImageURL ?? "", square: item.cardIsSquare)
                .overlay(alignment: .topTrailing) {
                    if hasUserData {
                        CheckToggle(isChecked: obtained == total && total > 0)
                            .offset(x: -4, y: 4)
                    }
                }
            CardContentView(title: item.cardTitle, rarity: item.cardRarity, style: item.cardStyle, label: item.cardLabel, obtained: obtained, total: total, showProgress: hasUserData, layout: layout)
        }
    }

    private var rowLayout: some View {
        HStack(alignment: .top, spacing: 10) {
            CardMediaView(url: item.cardImageURL ?? "", square: item.cardIsSquare)
                .frame(width: 100)
                .overlay(alignment: .topTrailing) {
                    if hasUserData {
                        CheckToggle(isChecked: obtained == total && total > 0, size: .sm)
                            .offset(x: -2, y: 2)
                    }
                }
            CardContentView(title: item.cardTitle, rarity: item.cardRarity, style: item.cardStyle, label: item.cardLabel, obtained: obtained, total: total, showProgress: hasUserData, layout: layout)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CardMediaView: View {
    let url: String
    let square: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            case .success(let image):
                ZStack {
                    Color(Color.themeSurfaceContainerLowest)
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity
                        )
                        .clipped()
                }
            case .failure:
                ZStack {
                    Color(.systemGroupedBackground)
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            @unknown default:
                EmptyView()
            }
        }
        .aspectRatio(square ? 1/1 : 2/3, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(Rectangle())
        .border(Color.themeOutlineVariant, width: 1)
    }
}

struct CardContentView: View {
    let title: String
    let rarity: Int?
    let style: String
    let label: String
    let obtained: Int
    let total: Int
    let showProgress: Bool
    let layout: CardLayout

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2)
                .fontDesign(.serif)
                .foregroundColor(Color.themeOnSurface)
                .lineLimit(1)

            Group {
                if layout == .card {
                    HStack {
                        subtitleText
                        Spacer()
                        rarityText
                    }
                } else {
                    subtitleText
                    rarityText
                    Spacer()
                }
            }
            .font(.caption)
            .foregroundColor(Color.themeSecondary)

            if showProgress {
                CompletionProgress(obtained: obtained, total: total)
            }
        }
        .padding(.top, layout == .card ? 14 : 0)
        .overlay(alignment: .top) {
            if layout == .card {
                Color.themeOutline.frame(height: 2)
            }
        }
    }

    @ViewBuilder
    private var subtitleText: some View {
        HStack(spacing: 2) {
            if !label.isEmpty { Text(label.uppercased()).lineLimit(1) }
            if !label.isEmpty && !style.isEmpty { Text("•") }
            if !style.isEmpty { Text(style.uppercased()).lineLimit(1) }
        }
    }

    @ViewBuilder
    private var rarityText: some View {
        if let rarity {
            Rarity(rarity: rarity, long: layout == .row && true)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Divider()
            HStack(spacing: 10) {
                CardView(item: SeedData.eurekaSetComplete)
                CardView(item: SeedData.eurekaSetPartial)
            }
            Divider()
            CardView(item: SeedData.eurekaSetComplete, layout: .row)
            CardView(item: SeedData.eurekaSetPartial, layout: .row)
            Divider()
            CardView(item: SeedData.variantJacket, layout: .row)
            CardView(item: SeedData.variantHat, layout: .row)
        }
        .padding()
    }
}
