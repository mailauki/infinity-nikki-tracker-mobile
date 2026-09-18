//
//  SeasonsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI
import Supabase

struct SeasonsView: View {
    @State private var seasons: [Season] = []
    @State private var seasonStats: [String: SeasonStats] = [:]
    @State private var isAuthenticated = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Seasons")
            LazyVStack(alignment: .leading, spacing: 30) {
                ForEach(groupedSeasons, id: \.location) { group in
                    VStack(alignment: .center, spacing: 12) {
//                        Text(group.location)
//                            .font(.title2)
//                            .fontDesign(.serif)
//                            .foregroundStyle(Color.themeOnSurface)
//                            .padding(.horizontal)
                        Text(group.location)
                            .font(.caption)
                            .foregroundStyle(Color.themeSecondary)

                        LazyVStack(spacing: 12) {
                            ForEach(Array(group.seasons.enumerated()), id: \.element.id) { index, season in
                                NavigationLink {
                                    SeasonDetail(season: season)
                                } label: {
                                    SeasonCard(
                                        season: season,
                                        number: group.seasons.count - index,
                                        stats: seasonStats[season.slug],
                                        isAuthenticated: isAuthenticated
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await fetchSeasons()
        }
        .overlay {
            if isLoading && seasons.isEmpty {
                ProgressView()
            }
        }
        .task {
            await fetchSeasons()
        }
        .navigationTitle("Seasons")
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
    }

    // MARK: - Grouping

    private struct SeasonGroupDisplay {
        let location: String
        let seasons: [Season]
    }

    // Groups seasons by location (e.g. Itzaland, Wishfield), preserving first-seen
    // order, with the newest season shown first within each location.
    private var groupedSeasons: [SeasonGroupDisplay] {
        var order: [String] = []
        var buckets: [String: [Season]] = [:]
        for season in seasons {
            let key = season.locationTitle ?? season.location ?? "Other"
            if buckets[key] == nil {
                buckets[key] = []
                order.append(key)
            }
            buckets[key]?.append(season)
        }
        return order.map { key in
            SeasonGroupDisplay(location: key, seasons: (buckets[key] ?? []).sorted { $0.id > $1.id })
        }
    }

    // MARK: - Data Methods

    func fetchSeasons() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            seasons = try await supabase.from("seasons")
                .select(Season.supabaseSelect)
                .order("id", ascending: true)
                .execute()
                .value

            print("✅ Successfully loaded \(seasons.count) seasons")
        } catch {
            print("❌ Seasons fetch error:")
            dump(error)
            errorMessage = "Failed to fetch seasons: \(error.localizedDescription)"
        }

        await loadStats()
    }

    // Builds per-season (and per-group-or-category-within-season) obtained/total
    // counts across outfits, makeup, and momo cloaks, for the completion chip and
    // glance list. Seasons with `useSeasonGroups` roll their categories up into their
    // parent season group and count by piece (variant); other seasons list by season
    // category and count by card (set).
    private func loadStats() async {
        async let outfitsResult = fetchAllOutfits()
        async let makeupResult = fetchAllMakeup()
        async let cloaksResult = fetchAllCloaks()
        async let categoriesResult = fetchSeasonCategories()
        async let groupsResult = fetchSeasonGroups()

        var (outfits, makeup, momoCloaks, categories, groups) = await (outfitsResult, makeupResult, cloaksResult, categoriesResult, groupsResult)

        if let user = try? await supabase.auth.session.user {
            outfits = await outfits.applyingObtainedOutfits(userId: user.id)
            makeup = await makeup.applyingObtainedMakeup(userId: user.id)
            momoCloaks = await momoCloaks.applyingObtainedMomoCloaks(userId: user.id)
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }

        let categoryTitles = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.title) })
        let categoryOrder = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.categoryId) })
        let categoryToGroup = Dictionary(uniqueKeysWithValues: categories.map { ($0.slug, $0.seasonGroup ?? "") })
        let groupTitles = Dictionary(uniqueKeysWithValues: groups.map { ($0.slug, $0.title) })
        let groupOrder = Dictionary(uniqueKeysWithValues: groups.map { ($0.slug, $0.groupId) })

        let outfitsBySeason = Dictionary(grouping: outfits) { $0.seasons ?? "" }
        let makeupBySeason = Dictionary(grouping: makeup) { $0.seasons ?? "" }
        let cloaksBySeason = Dictionary(grouping: momoCloaks) { $0.seasons ?? "" }

        var stats: [String: SeasonStats] = [:]
        for season in seasons {
            let seasonOutfits = outfitsBySeason[season.slug] ?? []
            let seasonMakeup = makeupBySeason[season.slug] ?? []
            let seasonCloaks = cloaksBySeason[season.slug] ?? []
            let useGroups = season.useSeasonGroups

            var buckets: [String: BucketAccum] = [:]
            accumulate(seasonOutfits, useGroups: useGroups, categoryToGroup: categoryToGroup, into: &buckets)
            accumulate(seasonMakeup, useGroups: useGroups, categoryToGroup: categoryToGroup, into: &buckets)
            accumulate(seasonCloaks, useGroups: useGroups, categoryToGroup: categoryToGroup, into: &buckets)

            let order = useGroups ? groupOrder : categoryOrder
            let titles = useGroups ? groupTitles : categoryTitles

            let categoryStats = buckets
                .map { slug, accum -> SeasonCategoryStat in
                    let title = slug.isEmpty ? "Uncategorized" : (titles[slug] ?? slug.capitalized)
                    // Season groups are counted by piece (variant); season categories by card (set).
                    let obtained = useGroups ? accum.pieceObtained : accum.cardCompleteCount
                    let total = useGroups ? accum.pieceTotal : accum.cardCount
                    return SeasonCategoryStat(slug: slug, title: title, obtained: obtained, total: total)
                }
                .sorted { lhs, rhs in
                    if lhs.slug.isEmpty != rhs.slug.isEmpty { return rhs.slug.isEmpty }
                    let lhsOrder = order[lhs.slug] ?? Int.max
                    let rhsOrder = order[rhs.slug] ?? Int.max
                    return lhsOrder != rhsOrder ? lhsOrder < rhsOrder : lhs.slug < rhs.slug
                }

            // The season-level completion percent always reflects individual pieces,
            // regardless of whether the glance list above counts by card or by piece.
            let pieceObtained = seasonOutfits.reduce(0) { $0 + $1.cardObtained }
                + seasonMakeup.reduce(0) { $0 + $1.cardObtained }
                + seasonCloaks.reduce(0) { $0 + $1.cardObtained }
            let pieceTotal = seasonOutfits.reduce(0) { $0 + $1.cardTotal }
                + seasonMakeup.reduce(0) { $0 + $1.cardTotal }
                + seasonCloaks.reduce(0) { $0 + $1.cardTotal }

            stats[season.slug] = SeasonStats(obtained: pieceObtained, total: pieceTotal, categories: categoryStats)
        }

        seasonStats = stats
    }

    // Tallies one item's piece (variant) counts and card (set) completion into the
    // bucket keyed by either its season category or, when `useGroups` is true, that
    // category's parent season group.
    private func accumulate<Item: CardDisplayable & DetailDisplayable>(
        _ items: [Item],
        useGroups: Bool,
        categoryToGroup: [String: String],
        into buckets: inout [String: BucketAccum]
    ) {
        for item in items {
            let categorySlug = item.detailSeasonCategory ?? ""
            let key = useGroups ? (categorySlug.isEmpty ? "" : (categoryToGroup[categorySlug] ?? "")) : categorySlug
            var accum = buckets[key] ?? BucketAccum()
            accum.pieceObtained += item.cardObtained
            accum.pieceTotal += item.cardTotal
            accum.cardCount += 1
            if item.cardTotal > 0 && item.cardObtained == item.cardTotal {
                accum.cardCompleteCount += 1
            }
            buckets[key] = accum
        }
    }

    private func fetchAllOutfits() async -> [OutfitSet] {
        do {
            return try await supabase.from("outfit_sets")
                .select(OutfitSet.supabaseSelect)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load outfit stats: \(error)")
            return []
        }
    }

    private func fetchAllMakeup() async -> [MakeupSet] {
        do {
            return try await supabase.from("makeup_sets")
                .select(MakeupSet.supabaseSelect)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load makeup stats: \(error)")
            return []
        }
    }

    private func fetchAllCloaks() async -> [MomoCloak] {
        do {
            return try await supabase.from("momo_cloaks")
                .select(MomoCloak.supabaseSelect)
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load cloak stats: \(error)")
            return []
        }
    }

    private func fetchSeasonCategories() async -> [SeasonCategory] {
        do {
            return try await supabase.from("season_categories")
                .select("id, slug, title, image_url, season_group")
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season categories: \(error)")
            return []
        }
    }

    private func fetchSeasonGroups() async -> [SeasonGroup] {
        do {
            return try await supabase.from("season_groups")
                .select("id, slug, title, image_url")
                .execute()
                .value
        } catch {
            print("⚠️ Failed to load season groups: \(error)")
            return []
        }
    }
}

private struct SeasonStats {
    let obtained: Int
    let total: Int
    let categories: [SeasonCategoryStat]
}

private struct SeasonCategoryStat: Identifiable {
    var id: String { slug }
    let slug: String
    let title: String
    let obtained: Int
    let total: Int
}

private struct BucketAccum {
    var pieceObtained = 0
    var pieceTotal = 0
    var cardCount = 0
    var cardCompleteCount = 0
}

private struct SeasonCard: View {
    let season: Season
    let number: Int
    let stats: SeasonStats?
    let isAuthenticated: Bool

    private var completionPercent: Int? {
        guard isAuthenticated, let stats, stats.total > 0 else { return nil }
        return Int((Double(stats.obtained) / Double(stats.total) * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(String(format: "%02d", number))
                    .font(.caption)
                    .foregroundStyle(Color.themeSecondary)

                Text(season.title)
                    .font(.title3)
                    .fontDesign(.serif)
                    .foregroundStyle(Color.themeOnSurface)
                    .lineLimit(2)

                Spacer()

                if let completionPercent {
                    Chip(label: "\(completionPercent)%")
                }
            }
            .padding(.bottom, 6)

            CardMediaBanner(url: season.imageURL ?? "", narrow: true)

            CardSeasonList(categories: stats?.categories ?? [], isAuthenticated: isAuthenticated)

            HStack(spacing: 4) {
                Text("View all")
                Image(systemName: "chevron.right")
            }
            .font(.caption)
            .foregroundStyle(Color.themePrimary)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CardMediaBanner: View {
    var url: String
    var narrow: Bool = false
    
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
                    //                        .opacity(0.75) // TODO: Apply to dark mode
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
        .aspectRatio(narrow ? 5/1.5 : 16/9, contentMode: .fill)
        .frame(maxWidth: .infinity)
        .clipShape(Rectangle())
        .border(Color.themeOutlineVariant, width: 1)
    }
}

private struct CardSeasonList: View {
    let categories: [SeasonCategoryStat]
    let isAuthenticated: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if categories.isEmpty {
                Text("No items yet")
                    .font(.caption)
                    .foregroundStyle(Color.themeOnSurfaceVariant)
            } else {
                ForEach(categories) { category in
                    HStack {
                        Text(category.title)
                        Spacer()
                        if isAuthenticated {
                            CompletionProgress(obtained: category.obtained, total: category.total, size: .mini)
                        } else {
                            Text("\(category.total)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 14)
        .overlay(alignment: .top) {
            Color.themeOutline.frame(height: 2)
        }
    }
}

#Preview {
    NavigationStack {
        SeasonsView()
    }
}
