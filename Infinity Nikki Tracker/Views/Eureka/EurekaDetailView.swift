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

    @AppStorage("eurekaIsGrid") private var isGrid = true
    @State private var showDetailCard = false
    @State private var selectedColor = "all"

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // Colors sorted alphabetically, with iridescent pushed to the end.
    private var colorOptions: [FilterOption] {
        let colors = eurekaSet.colors
            .map { color -> (option: FilterOption, isIridescent: Bool) in
                let lowered = color.slug.lowercased()
                let isIridescent = lowered.contains("iridescent") || lowered.contains("irridescent")
                let option = FilterOption(id: color.slug, label: (color.title ?? color.slug).capitalized, imageName: color.slug)
                return (option, isIridescent)
            }
            .sorted { lhs, rhs in
                lhs.isIridescent != rhs.isIridescent ? !lhs.isIridescent : lhs.option.label < rhs.option.label
            }
            .map(\.option)
        return [FilterOption(id: "all", label: "All")] + colors
    }

    private var filteredVariants: [EurekaVariant] {
        guard selectedColor != "all" else { return eurekaSet.eurekaVariants }
        return eurekaSet.eurekaVariants.filter { $0.color == selectedColor }
    }

    var body: some View {
        VStack(spacing: 0) {
            if eurekaSet.colors.count > 1 {
                FilterChipBar(options: colorOptions, selection: $selectedColor)
            }

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
        }
        .navigationTitle(eurekaSet.title)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDetailCard = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isGrid.toggle()
                } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                }
            }
        }
        .sheet(isPresented: $showDetailCard) {
            DetailCardView(item: eurekaSet, progress: progress)
        }
    }

    private var listContent: some View {
        List {
            ForEach(filteredVariants) { eurekaVariant in
                CardView(item: eurekaVariant, layout: .row)
            }.listRowBackground(Color.themeSurfaceContainerLow)
        }
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredVariants) { eurekaVariant in
                    CardView(item: eurekaVariant, layout: .card)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom)
        }
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
