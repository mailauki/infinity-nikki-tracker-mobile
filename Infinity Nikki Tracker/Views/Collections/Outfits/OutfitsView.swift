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
        ScrollView {
            AuthBanner(collectionLabel: "Outfits")
            Group {
                if isGrid {
                    // Grid Layout View
                    outfitGridView
                } else {
                    // List Layout View
                    outfitListView
                }
            }
        }
        .refreshable {
            await fetchOutfits()
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
    }
    
    // MARK: - View Components
    
    var outfitListView: some View {
        LazyVStack(spacing: 10) {
            ForEach(outfitSets) { outfitSet in
                NavigationLink {
                    OutfitDetail(outfitSet: outfitSet)
                } label: {
                    CardView(item: outfitSet, layout: .row)
                }
            }
        }
        .padding()
    }
    
    var outfitGridView: some View {
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
    
    // MARK: - Data Methods
    
    func fetchOutfits() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            var sets: [OutfitSet] = try await supabase.from("outfit_sets")
                .select(OutfitSet.supabaseSelect)
                .order("id", ascending: true)
                .execute()
                .value
            
            // Group each evolution with its base set (by the base set's id), then
            // order within that group: base set first, evolutions in between, glowup last.
            let idBySlug = Dictionary(uniqueKeysWithValues: sets.map { ($0.slug, $0.id) })
            func evolutionPriority(_ order: Int) -> Int {
                if order == 1 { return 0 }
                if order == 0 { return 2 }
                return 1
            }
            sets.sort { lhs, rhs in
                let lhsGroup = lhs.baseSet.flatMap { idBySlug[$0] } ?? lhs.id
                let rhsGroup = rhs.baseSet.flatMap { idBySlug[$0] } ?? rhs.id
                if lhsGroup != rhsGroup { return lhsGroup < rhsGroup }
                
                let lhsPriority = evolutionPriority(lhs.order)
                let rhsPriority = evolutionPriority(rhs.order)
                return lhsPriority != rhsPriority ? lhsPriority < rhsPriority : lhs.order < rhs.order
            }
            
            print("✅ Successfully loaded \(sets.count) outfit sets")
            
            if let user = try? await supabase.auth.session.user {
                sets = await sets.applyingObtainedOutfits(userId: user.id)
            }
            
            outfitSets = sets
            
            // Optionally fetch categories and colors if needed for filtering
            do {
                categories = try await supabase.from("outfit_categories")
                    .select("id, slug, title, image_url")
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
}

#Preview {
    NavigationStack {
        OutfitsView()
    }
}
