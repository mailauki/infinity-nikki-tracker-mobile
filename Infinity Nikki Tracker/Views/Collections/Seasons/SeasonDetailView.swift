//
//  SeasonDetailView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/17/26.
//

import SwiftUI
import Supabase

struct SeasonDetail: View {
    let season: Season

    @AppStorage("seasonIsGrid") private var isGrid = true
    @State private var outfitSets: [OutfitSet] = []
    @State private var makeupSets: [MakeupSet] = []
    @State private var cloaks: [MomoCloak] = []
    @State private var categoryTitles: [String: String] = [:]
    @State private var categoryOrder: [String: Int] = [:]
    @State private var selectedCloak: MomoCloak?
    @State private var isLoading = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var totalItems: Int { outfitSets.count + makeupSets.count + cloaks.count }

    private var statsLine: String? {
        var parts: [String] = []
        if !outfitSets.isEmpty { parts.append("\(outfitSets.count) outfit\(outfitSets.count == 1 ? "" : "s")") }
        if !makeupSets.isEmpty { parts.append("\(makeupSets.count) makeup") }
        if !cloaks.isEmpty { parts.append("\(cloaks.count) cloak\(cloaks.count == 1 ? "" : "s")") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            header

            if isLoading && totalItems == 0 {
                ProgressView().padding(.top, 40)
            } else if totalItems == 0 {
                Text("No items found for this season yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.themeOnSurfaceVariant)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(allCategorySlugs, id: \.self) { slug in
                        categorySection(slug: slug)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(season.title)
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .refreshable {
            await loadAll()
        }
        .task {
            await loadAll()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isGrid.toggle()
                } label: {
                    Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                }
            }
        }
        .sheet(item: $selectedCloak) { cloak in
            DetailCardView(item: cloak)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardMediaBanner(url: season.imageURL ?? "")

            if let description = season.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.themeOnSurfaceVariant)
            }

            if let statsLine {
                Text(statsLine)
                    .font(.caption)
                    .foregroundStyle(Color.themeSecondary)
            }
        }
        .padding()
    }

    // MARK: - Sections

    // Every season category slug present among this season's items (outfits, makeup,
    // or cloaks), ordered by the category's id, with uncategorized items ("") trailing.
    private var allCategorySlugs: [String] {
        let slugs = Set(
            outfitSets.map { $0.detailSeasonCategory ?? "" } +
            makeupSets.map { $0.detailSeasonCategory ?? "" } +
            cloaks.map { $0.detailSeasonCategory ?? "" }
        )
        return slugs.sorted { lhs, rhs in
            if lhs.isEmpty != rhs.isEmpty { return rhs.isEmpty }
            let lhsOrder = categoryOrder[lhs] ?? Int.max
            let rhsOrder = categoryOrder[rhs] ?? Int.max
            return lhsOrder != rhsOrder ? lhsOrder < rhsOrder : lhs < rhs
        }
    }

    @ViewBuilder
    private func categorySection(slug: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if !slug.isEmpty {
                Text(categoryTitles[slug] ?? slug.capitalized)
                    .font(.title2)
                    .fontDesign(.serif)
                    .foregroundStyle(Color.themeOnSurface)
            }

            typeSubsection(title: "Outfits", items: outfitSets.filter { ($0.detailSeasonCategory ?? "") == slug }) { outfitSet in
                NavigationLink {
                    OutfitDetail(outfitSet: outfitSet)
                } label: {
                    CardView(item: outfitSet, layout: isGrid ? .card : .row)
                }
                .buttonStyle(.plain)
            }

            typeSubsection(title: "Makeup", items: makeupSets.filter { ($0.detailSeasonCategory ?? "") == slug }) { makeupSet in
                NavigationLink {
                    MakeupDetail(makeupSet: makeupSet)
                } label: {
                    CardView(item: makeupSet, layout: isGrid ? .card : .row)
                }
                .buttonStyle(.plain)
            }

            typeSubsection(title: "Momo Cloaks", items: cloaks.filter { ($0.detailSeasonCategory ?? "") == slug }) { cloak in
                Button {
                    selectedCloak = cloak
                } label: {
                    CardView(item: cloak, layout: isGrid ? .card : .row)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func typeSubsection<Item: Identifiable, Content: View>(
        title: String,
        items: [Item],
        @ViewBuilder link: @escaping (Item) -> Content
    ) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.themeSecondary)

                if isGrid {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(items) { link($0) }
                    }
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(items) { link($0) }
                    }
                }
            }
        }
    }

    // MARK: - Data Methods

    private func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        async let outfitsResult = fetchOutfitSets()
        async let makeupResult = fetchMakeupSets()
        async let cloaksResult = fetchCloakSets()
        async let categoriesResult = fetchSeasonCategories()

        let (outfits, makeup, momoCloaks, categories) = await (outfitsResult, makeupResult, cloaksResult, categoriesResult)

        categoryTitles = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.title) })
        categoryOrder = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.categoryId) })

        var loadedOutfits = outfits
        var loadedMakeup = makeup
        var loadedCloaks = momoCloaks

        if let user = try? await supabase.auth.session.user {
            loadedOutfits = await loadedOutfits.applyingObtainedOutfits(userId: user.id)
            loadedMakeup = await loadedMakeup.applyingObtainedMakeup(userId: user.id)
            loadedCloaks = await loadedCloaks.applyingObtainedMomoCloaks(userId: user.id)
        }

        outfitSets = loadedOutfits
        makeupSets = loadedMakeup
        cloaks = loadedCloaks
    }

    private func fetchOutfitSets() async -> [OutfitSet] {
        do {
            return try await supabase.from("outfit_sets")
                .select(OutfitSet.supabaseSelect)
                .eq("seasons", value: season.slug)
                .order("id", ascending: true)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season outfits: \(error)")
            return []
        }
    }

    private func fetchMakeupSets() async -> [MakeupSet] {
        do {
            return try await supabase.from("makeup_sets")
                .select(MakeupSet.supabaseSelect)
                .eq("seasons", value: season.slug)
                .order("id", ascending: true)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season makeup: \(error)")
            return []
        }
    }

    private func fetchCloakSets() async -> [MomoCloak] {
        do {
            return try await supabase.from("momo_cloaks")
                .select(MomoCloak.supabaseSelect)
                .eq("seasons", value: season.slug)
                .order("id", ascending: true)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season cloaks: \(error)")
            return []
        }
    }

    private func fetchSeasonCategories() async -> [SeasonCategory] {
        do {
            return try await supabase.from("season_categories")
                .select("id, slug, title, image_url")
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season categories: \(error)")
            return []
        }
    }
}

#Preview {
    NavigationStack {
        SeasonDetail(season: .init(
            id: 1,
            slug: "bloom_beneath_bright_skies",
            title: "Bloom Beneath Bright Skies",
            description: "Step bravely toward the bright skies, and the flowers of the heart will bloom at last.",
            imageURL: "",
            altImageURL: "",
            location: "itzaland",
            locationTitle: "Itzaland",
            useSeasonGroups: false,
            createdAt: "",
            updatedAt: ""
        ))
    }
}
