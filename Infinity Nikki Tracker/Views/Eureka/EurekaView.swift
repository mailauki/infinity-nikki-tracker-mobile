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
    
    @AppStorage("eurekaIsGrid") private var isGrid = true
    
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
                    eurekaGridView
                } else {
                    // List Layout View
                    eurekaListView
                }
            }
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
            Text("Select a Eureka")
                .navigationTitle("Eureka")
        }
    }
    
    // MARK: - View Components
    
    private var eurekaListView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Eureka")
            LazyVStack(spacing: 10) {
                ForEach(eurekaSets) { eurekaSet in
                    NavigationLink {
                        EurekaDetail(eurekaSet: eurekaSet)
                    } label: {
                        CardView(item: eurekaSet, layout: .row)
                    }.listRowBackground(Color.themeSurfaceContainerLow)
                }
            }
            .padding()
        }
        .refreshable {
            await fetchEureka()
        }
    }
    
    private var eurekaGridView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Eureka")
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(eurekaSets) { eurekaSet in
                    NavigationLink {
                        EurekaDetail(eurekaSet: eurekaSet)
                    } label: {
                        CardView(item: eurekaSet)
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
            var sets: [EurekaSet] = try await supabase.from("eureka_sets")
                .select(
                    """
                    id,
                    slug,
                    title,
                    description,
                    rarity,
                    style,
                    label,
                    updated_at,
                    eureka_set_trials ( trial ),
                    eureka_variants (
                        id,
                        slug,
                        eureka_set,
                        color,
                        category,
                        image_url,
                        default
                    )
                    """
                )
                .order("id", ascending: true)
                .order("id", ascending: true, referencedTable: "eureka_variants")
                .execute()
                .value

            print("✅ Successfully loaded \(sets.count) eureka sets")

            if let user = try? await supabase.auth.session.user {
                sets = await applyObtained(to: sets, userId: user.id)
            }

            eurekaSets = sets

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

    private func applyObtained(to sets: [EurekaSet], userId: UUID) async -> [EurekaSet] {
        do {
            let obtainedRecords: [ObtainedEureka] = try await supabase
                .from("obtained_eureka")
                .select("id, eureka_set, category, color")
                .eq("user_id", value: userId)
                .execute()
                .value

            let obtainedKeys = Set(obtainedRecords.compactMap { record -> String? in
                guard let es = record.eurekaSet, let cat = record.category, let col = record.color else { return nil }
                return "\(es)|\(cat)|\(col)"
            })

            return sets.map { set in
                set.withVariants(set.eurekaVariants.map { variant in
                    let key = "\(variant.eurekaSet ?? "")|\(variant.category ?? "")|\(variant.color ?? "")"
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
    EurekaView()
}
