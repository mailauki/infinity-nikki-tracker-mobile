//
//  EurekaDetail.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI

struct EurekaDetail: View {
    let eurekaSet: EurekaSet
    let progress: Float = 0

    @AppStorage("eurekaDetailIsGrid") private var isGrid = false

    private let columns = [
        GridItem(.flexible()),
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
            if eurekaSet.eurekaVariants.isEmpty {
                ProgressView()
            }
        }
        .navigationTitle(eurekaSet.title)
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
                ForEach(eurekaSet.eurekaVariants) { eurekaVariant in
                    EurekaRow(eurekaVariant: eurekaVariant)
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
                ForEach(eurekaSet.eurekaVariants) { eurekaVariant in
                    CardView(item: eurekaVariant, layout: .card)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    var detailHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: eurekaSet.imageURL ?? "")) { phase in
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
            
            Text(eurekaSet.title)
                .font(.title)
                .foregroundStyle(Color.themeOnSurface)
                
            HStack {
                if let rarity = eurekaSet.rarity {
                    Rarity(rarity: rarity)
                }
                
                Spacer()
                
                ProgressChip(progress: progress)
            }
            
            HStack {
                if let style = eurekaSet.style {
                    Text(style.capitalized)
                        .foregroundStyle(Color.themeOnSurfaceVariant)
                }
                
                Spacer()
                
                if let label = eurekaSet.label {
                    Chip(label: label)
                }
            }
            .foregroundStyle(Color.themeSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)
    }
}

#Preview {
    EurekaDetail(eurekaSet: .init(
        id: 1,
        slug: "test",
        title: "Test name",
        rarity: 5,
        style: "elegant",
        label: "limited",
        description: nil,
        createdAt: nil,
        updatedAt: nil,
        eurekaVariants: []
    ))
}
