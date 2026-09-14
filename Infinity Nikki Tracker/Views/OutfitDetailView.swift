//
//  EurekaDetail.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI

struct OutfitDetail: View {
    let outfitSet: OutfitSet
    let progress: Float = 0

    @AppStorage("outfitIsGrid") private var isGrid = true

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Group {
            if isGrid {
                gridContent
            } else {
                listContent
            }
        }
        .overlay {
            if outfitSet.outfitVariants.isEmpty {
                ProgressView()
            }
        }
        .navigationTitle(outfitSet.title)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isGrid.toggle()
                } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                }
            }
        }
    }

    private var listContent: some View {
        List {
            Section(header: detailHeader) {
                ForEach(outfitSet.outfitVariants) { outfitVariant in
                    CardView(item: outfitVariant, layout: .row)
                }.listRowBackground(Color.themeSurfaceContainerLow)
            }
        }
    }

    private var gridContent: some View {
        ScrollView {
            detailHeader
                .padding(.horizontal)
                .padding(.top, 20)

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(outfitSet.outfitVariants) { outfitVariant in
                    CardView(item: outfitVariant, layout: .card)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    var detailHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: outfitSet.imageURL ?? "")) { phase in
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
            
            Text(outfitSet.title)
                .font(.title)
                .foregroundStyle(Color.themeOnSurface)
                
            HStack {
                if let rarity = outfitSet.rarity {
                    Rarity(rarity: rarity, long: true)
                    .foregroundColor(Color.themeSecondary)
                }
                
                Spacer()
                
                ProgressChip(progress: progress)
            }
            
            HStack {
                if let style = outfitSet.style {
                    Text(style.capitalized).foregroundColor(Color.themeOnSurfaceVariant)
                }
                
                Spacer()
                
                if let label = outfitSet.label {
                    Chip(label: label)
                }
            }
            
            HStack {
                if let season = outfitSet.seasons {
                    Text(season).foregroundColor(Color.themePrimary)
                }
                
                Spacer()
                
                if let seasonCategory = outfitSet.seasonCategory {
                    Text(seasonCategory).foregroundColor(Color.themeOnSurfaceVariant)
                }
            }
            
            if let ability = outfitSet.ability {
                Chip(label: ability)
            }
            
            Text(outfitSet.description ?? "")
                .font(.body)
                .foregroundStyle(Color.themeOnSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
}

#Preview {
    OutfitDetail(outfitSet: .init(
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
        carouselImages: [],
    ))
}
