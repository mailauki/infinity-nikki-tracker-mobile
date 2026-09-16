//
//  EurekaDetail.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI
import Supabase

struct OutfitDetail: View {
    let outfitSet: OutfitSet
    let progress: Float = 0

    @AppStorage("outfitIsGrid") private var isGrid = true
    @State private var showDetailCard = false
    @State private var evolutionSets: [OutfitSet] = []
    @State private var selectedEvolutionSlug = ""
    @State private var categoryOrder: [String: Int] = [:]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // The base set plus any sets that evolve from it, falling back to the
    // originally passed set until the evolution family finishes loading.
    private var currentSet: OutfitSet {
        evolutionSets.first { $0.slug == selectedEvolutionSlug } ?? outfitSet
    }

    // Variants ordered by their category's id, falling back to the end for
    // any category we don't have an order for yet.
    private var sortedVariants: [OutfitVariant] {
        currentSet.outfitVariants.sorted {
            let lhs = $0.outfitCategory.flatMap { categoryOrder[$0] } ?? Int.max
            let rhs = $1.outfitCategory.flatMap { categoryOrder[$0] } ?? Int.max
            return lhs < rhs
        }
    }

    // Base set always first, then evolutions in their fetched order, with glowup
    // stages pushed to the end regardless of that order.
    private var evolutionOptions: [FilterOption] {
        evolutionSets
            .enumerated()
            .map { index, set -> (option: FilterOption, priority: Int, index: Int) in
                let isBase = set.baseSet == nil
                let isGlowup = set.order == 0
                let baseLabel = isBase ? "Base" : (set.subtitle ?? set.title)
                let label = isGlowup ? "✦ \(baseLabel)" : baseLabel
                let priority = isBase ? 0 : (isGlowup ? 2 : 1)
                return (FilterOption(id: set.slug, label: label), priority, index)
            }
            .sorted { lhs, rhs in
                lhs.priority != rhs.priority ? lhs.priority < rhs.priority : lhs.index < rhs.index
            }
            .map(\.option)
    }

    var body: some View {
        VStack(spacing: 0) {
            if evolutionOptions.count > 1 {
                FilterChipBar(options: evolutionOptions, selection: $selectedEvolutionSlug)
            }

            Group {
                if isGrid {
                    gridContent
                } else {
                    listContent
                }
            }
            .overlay {
                if currentSet.outfitVariants.isEmpty {
                    ProgressView()
                }
            }
        }
        .navigationTitle(currentSet.title)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .task {
            await loadEvolutionSets()
        }
        .task {
            await loadCategoryOrder()
        }
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
            DetailCardView(item: currentSet, progress: progress)
        }
    }

    private var listContent: some View {
        List {
            ForEach(sortedVariants) { outfitVariant in
                CardView(item: outfitVariant, layout: .row)
            }.listRowBackground(Color.themeSurfaceContainerLow)
        }
    }

    private var gridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedVariants) { outfitVariant in
                    CardView(item: outfitVariant, layout: .card)
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom)
        }
    }

    private func loadCategoryOrder() async {
        guard categoryOrder.isEmpty else { return }
        do {
            let categories: [OutfitCategory] = try await supabase.from("outfit_categories")
                .select("id, slug, title")
                .execute()
                .value
            categoryOrder = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.categoryId) })
        } catch {
            print("⚠️ Failed to load category order: \(error)")
        }
    }

    private func loadEvolutionSets() async {
        guard evolutionSets.isEmpty else { return }
        selectedEvolutionSlug = outfitSet.slug

        let rootSlug = outfitSet.baseSet ?? outfitSet.slug
        do {
            var sets: [OutfitSet] = try await supabase.from("outfit_sets")
                .select(OutfitSet.supabaseSelect)
                .or("slug.eq.\(rootSlug),base_set.eq.\(rootSlug)")
                .order("order", ascending: true)
                .execute()
                .value

            if let user = try? await supabase.auth.session.user {
                sets = await sets.applyingObtainedOutfits(userId: user.id)
            }

            evolutionSets = sets.isEmpty ? [outfitSet] : sets
        } catch {
            print("⚠️ Failed to load evolution sets: \(error)")
            evolutionSets = [outfitSet]
        }
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
