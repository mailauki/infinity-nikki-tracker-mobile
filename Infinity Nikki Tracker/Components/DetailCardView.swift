//
//  DetailCardView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/15/26.
//

import SwiftUI

struct DetailCardView<Item: DetailDisplayable>: View {
    let item: Item
    var progress: Float = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                AsyncImage(url: URL(string: item.cardImageURL ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 60, height: 40)
                            .foregroundStyle(.placeholder.opacity(0.5))
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 200, height: 200)

                Text(item.cardTitle)
                    .font(.title)
                    .foregroundStyle(Color.themeOnSurface)

                HStack {
                    if let rarity = item.cardRarity {
                        RarityStars(rarity: rarity, long: true)
                            .foregroundColor(Color.themeSecondary)
                    }

                    Spacer()

                    ProgressChip(progress: progress)
                }

                HStack {
                    if !item.cardStyle.isEmpty {
                        Text(item.cardStyle.capitalized).foregroundColor(Color.themePrimary)
                    }

                    Spacer()

                    if !item.cardLabel.isEmpty {
                        Chip(label: item.cardLabel)
                    }
                }

                if item.detailSeasons != nil || item.detailSeasonCategory != nil {
                    HStack {
                        if let seasons = item.detailSeasons {
                            Text(seasons).foregroundColor(Color.themePrimary)
                        }

                        Spacer()

                        if let seasonCategory = item.detailSeasonCategory {
                            Text(seasonCategory).foregroundColor(Color.themeOnSurfaceVariant)
                        }
                    }
                }

                if let ability = item.detailAbility {
                    Chip(label: ability)
                }

                if let description = item.detailDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.themeOnSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
    }
}

#Preview {
    DetailCardView(item: OutfitSet(
        id: 1,
        slug: "test",
        title: "Test name",
        subtitle: nil,
        rarity: 5,
        style: "elegant",
        label: "fantasy",
        label2: nil,
        ability: "shrinking",
        baseSet: nil,
        imageURL: "",
        altImageURL: "",
        description: "A Faewish Sprite says that wearing this can make a massive visitor shrink, as tiny as they can be! But the ability to fly doesn’t come with the package.",
        order: 1,
        handheldBaseOnly: false,
        seasonCategory: "Heart of Infinity",
        seasons: "Exploration Season",
        createdAt: "",
        updatedAt: "",
        outfitVariants: [],
        carouselImages: []
    ))
}
