//
//  EurekaView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 2/19/26.
//

import SwiftUI
import Supabase

struct EurekaView: View {
    @State private var eurekaSets: [EurekaSet] = []
    @State private var categories: [EurekaCategory] = []
    @State private var colors: [EurekaColor] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // MARK: - Constants
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            eurekaListView
                .overlay {
                    if isLoading && eurekaSets.isEmpty {
                        ProgressView()
                    }
                }
                .task {
                    await fetchEureka()
                }
                .navigationTitle("Eureka")
                .scrollContentBackground(.hidden)
                .background(Color.themeSurface)
#if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            Text("Select a Eureka")
                .navigationTitle("Eureka")
        }
    }
    
    // MARK: - View Components
    
    private var eurekaListView: some View {
        List {
            ForEach(eurekaSets) { eurekaSet in
                NavigationLink {
                    EurekaDetail(eurekaSet: eurekaSet)
                } label: {
                    EurekaSetRow(eurekaSet: eurekaSet)
                }.listRowBackground(Color.themeSurfaceContainerLow)
            }
        }
        .refreshable {
            await fetchEureka()
        }
    }
    
    private var eurekaGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(eurekaSets) { eurekaSet in
                    NavigationLink {
                        EurekaDetail(eurekaSet: eurekaSet)
                    } label: {
                        EurekaSetCard(eurekaSet: eurekaSet)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await fetchEureka()
        }
    }
    
    // MARK: - Data Methods
    
    func fetchEureka() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            eurekaSets = try await supabase.from("eureka_sets")
                .select(
                    """
                    id,
                    slug,
                    title,
                    rarity,
                    style,
                    label,
                    description,
                    created_at,
                    updated_at,
                    eureka_variants (
                        id,
                        slug,
                        eureka_set,
                        color,
                        category,
                        image_url,
                        default,
                        created_at,
                        updated_at
                    )
                    """
                )
                .order("id", ascending: true)
                .order("id", ascending: true, referencedTable: "eureka_variants")
                .execute()
                .value
            
            print("✅ Successfully loaded \(eurekaSets.count) eureka sets")
            
            // Optionally fetch categories and colors if needed for filtering
            do {
                categories = try await supabase.from("eureka_categories")
                    .select("slug, title, image_url")
                    .execute()
                    .value
                
                print("✅ Successfully loaded \(categories.count) categories")
            } catch {
                print("⚠️ Failed to load categories (non-critical): \(error)")
            }
            
            do {
                colors = try await supabase.from("eureka_colors")
                    .select("slug, title, image_url")
                    .execute()
                    .value
                
                print("✅ Successfully loaded \(colors.count) colors")
            } catch {
                print("⚠️ Failed to load colors (non-critical): \(error)")
            }
            
        } catch {
            print("❌ Eureka fetch error:")
            dump(error)
            errorMessage = "Failed to fetch eureka sets: \(error.localizedDescription)"
        }
    }
}

#Preview {
    EurekaView()
}
