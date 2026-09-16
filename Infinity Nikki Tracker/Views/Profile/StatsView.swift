//
//  StatsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import SwiftUI
import Supabase

struct StatsView: View {
    private static let defaultCollections: [CollectionItem] = [
        CollectionItem(icon: "tshirt", label: "Outfits"),
        CollectionItem(icon: "theatermask.and.paintbrush", label: "Makeup"),
        CollectionItem(icon: "bubbles.and.sparkles", label: "Eureka"),
        CollectionItem(icon: "pawprint", label: "Cloaks"),
    ]

    @State private var collections: [CollectionItem] = StatsView.defaultCollections
    @State private var selectedCollection: CollectionItem = StatsView.defaultCollections[2]

    @State private var eurekaSets: [EurekaSet] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Picker("Collection", selection: $selectedCollection) {
                    ForEach(collections) { item in
                        Image(systemName: item.icon)
                            .tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    switch selectedCollection.label {
                    case "Eureka":
                        EurekaStatsContent(eurekaSets: eurekaSets, isLoading: isLoading)
                    default:
                        PlaceholderStatsContent(label: selectedCollection.label)
                    }
                }
                .padding(.horizontal)
            }
        }
        .task { await fetchEureka() }
        .navigationTitle("Stats")
        .background(Color.themeSurface)
    }

    func fetchEureka() async {
        isLoading = true
        defer { isLoading = false }
        do {
            eurekaSets = try await supabase.from("eureka_sets")
                .select("""
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
                        updated_at,
                        obtained
                    )
                """)
                .order("id", ascending: true)
                .order("id", ascending: true, referencedTable: "eureka_variants")
                .execute()
                .value
        } catch {
            errorMessage = "Failed to load eureka data: \(error.localizedDescription)"
        }
    }
}

// MARK: - Eureka Stats

private struct EurekaStatsContent: View {
    let eurekaSets: [EurekaSet]
    let isLoading: Bool

    private var totalSets: Int { eurekaSets.count }

    private var totalVariants: Int {
        eurekaSets.reduce(0) { $0 + $1.eurekaVariants.count }
    }

    private var obtainedVariants: Int {
        eurekaSets.reduce(0) { $0 + $1.eurekaVariants.filter { $0.obtained == true }.count }
    }

    private var completedSets: Int {
        eurekaSets.filter { set in
            !set.eurekaVariants.isEmpty && set.eurekaVariants.allSatisfy { $0.obtained == true }
        }.count
    }

    private var uniqueCategories: Int {
        Set(eurekaSets.flatMap { $0.eurekaVariants.compactMap { $0.category } }).count
    }

    private var completionPercent: Double {
        guard totalVariants > 0 else { return 0 }
        return Double(obtainedVariants) / Double(totalVariants)
    }

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
        } else {
            VStack(spacing: 16) {
                // Overall progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Overall Completion")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(completionPercent * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    ProgressView(value: completionPercent)
                        .tint(Color.themePrimary)
                }
                .padding()
                .background(Color.themeSurfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Stat cards grid
                LazyVGrid(columns: statColumns, spacing: 12) {
                    StatCard(value: "\(totalSets)", label: "Sets")
                    StatCard(value: "\(completedSets)", label: "Completed")
                    StatCard(value: "\(totalVariants)", label: "Variants")
                    StatCard(value: "\(obtainedVariants)", label: "Obtained")
                    StatCard(value: "\(totalVariants - obtainedVariants)", label: "Remaining")
                    StatCard(value: "\(uniqueCategories)", label: "Categories")
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Placeholder

private struct PlaceholderStatsContent: View {
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("\(label) stats coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.themePrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.themeSurfaceContainer)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
