//
//  OutfitsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/13/26.
//

import SwiftUI
import Supabase

struct OutfitsView: View {
    @State private var outfitSets: [OutfitSet] = []
    @State private var categories: [OutfitCategory] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @AppStorage("outfitIsGrid") private var isGrid = true
    
    // MARK: - Constants
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            Group {
                if isGrid {
                    // Grid Layout View
                    outfitGridView
                } else {
                    // List Layout View
                    outfitListView
                }
            }
            .overlay {
                if isLoading && outfitSets.isEmpty {
                    ProgressView()
                }
            }
            .task {
                await fetchOutfits()
            }
            .navigationTitle("Outfits")
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
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            Text("Select a Outfit")
                .navigationTitle("Outfits")
        }
    }
    
    // MARK: - View Components
    
    private var outfitListView: some View {
        List {
            ForEach(outfitSets) { outfitSet in
                NavigationLink {
                    OutfitDetail(outfitSet: outfitSet)
                } label: {
                    CardView(item: outfitSet, layout: .row)
                }.listRowBackground(Color.themeSurfaceContainerLow)
            }
        }
        .refreshable {
            await fetchOutfits()
        }
    }
    
    private var outfitGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(outfitSets) { outfitSet in
                    NavigationLink {
                        OutfitDetail(outfitSet: outfitSet)
                    } label: {
                        CardView(item: outfitSet)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await fetchOutfits()
        }
    }
    
    // MARK: - Data Methods
    
    func fetchOutfits() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var sets: [OutfitSet] = try await supabase.from("outfit_sets")
                .select(
                    """
                    id,
                    slug,
                    title,
                    subtitle,
                    description,
                    rarity,
                    style,
                    label,
                    label_2,
                    ability,
                    seasons,
                    season_category,
                    "order",
                    base_set,
                    handheld_base_only,
                    season:seasons!outfit_sets_seasons_fkey ( title ),
                    seasonCategory:season_categories!outfit_sets_season_category_fkey ( title ),
                    image_url,
                    alt_image_url,
                    updated_at,
                    outfit_set_carousel_images (
                      id,
                      image_url,
                      sort_order
                    ),
                    outfit_variants (
                      id,
                      slug,
                      alt_slug,
                      outfit_set,
                      outfit_category,
                      title,
                      description,
                      rarity,
                      style,
                      label,
                      label_2,
                      image_url,
                      alt_image_url,
                      "default",
                      season_category,
                      seasons,
                      updated_at
                    )
                    """
                )
                .is("base_set", value: nil)
                .order("id", ascending: true)
                .execute()
                .value

            print("✅ Successfully loaded \(sets.count) outfit sets")

            if let user = try? await supabase.auth.session.user {
                sets = await applyObtained(to: sets, userId: user.id)
            }

            outfitSets = sets

            // Optionally fetch categories and colors if needed for filtering
            do {
                categories = try await supabase.from("outfit_categories")
                    .select("slug, title, image_url")
                    .execute()
                    .value

                print("✅ Successfully loaded \(categories.count) categories")
            } catch {
                print("⚠️ Failed to load categories (non-critical): \(error)")
            }

        } catch {
            print("❌ Eureka fetch error:")
            dump(error)
            errorMessage = "Failed to fetch eureka sets: \(error.localizedDescription)"
        }
    }

    private func applyObtained(to sets: [OutfitSet], userId: UUID) async -> [OutfitSet] {
        do {
            let obtainedRecords: [ObtainedOutfits] = try await supabase
                .from("obtained_outfit")
                .select("id, outfit_set, outfit_category, outfit_variant, user_id")
                .eq("user_id", value: userId)
                .execute()
                .value

            let obtainedKeys = Set(obtainedRecords.map { record in
                "\(record.outfitSet)|\(record.outfitCategory)|\(record.outfitVariant)"
            })

            return sets.map { set in
                set.withVariants(set.outfitVariants.map { variant in
                    let key = "\(variant.outfitSet ?? "")|\(variant.outfitCategory ?? "")|\(variant.slug)"
                    return variant.withObtained(obtainedKeys.contains(key))
                })
            }
        } catch {
            print("⚠️ Failed to load obtained data: \(error)")
            return sets
        }
    }
}
#Preview {
    OutfitsView()
}
