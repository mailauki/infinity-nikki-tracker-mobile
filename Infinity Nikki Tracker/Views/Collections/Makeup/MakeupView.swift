//
//  MakeupView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI
import Supabase

struct MakeupView: View {
    @State private var makeupSets: [MakeupSet] = []
    @State private var categories: [MakeupCategory] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    @AppStorage("makeupIsGrid") private var isGrid = true

    // MARK: - Constants

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    // MARK: - Body

    var body: some View {
        Group {
            if isGrid {
                // Grid Layout View
                makeupGridView
            } else {
                // List Layout View
                makeupListView
            }
        }
        .overlay {
            if isLoading && makeupSets.isEmpty {
                ProgressView()
            }
        }
        .task {
            await fetchMakeup()
        }
        .navigationTitle("Makeup")
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

    private var makeupListView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Makeup")
            LazyVStack(spacing: 10) {
                ForEach(makeupSets) { makeupSet in
                    NavigationLink {
                        MakeupDetail(makeupSet: makeupSet)
                    } label: {
                        CardView(item: makeupSet, layout: .row)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await fetchMakeup()
        }
    }

    private var makeupGridView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Makeup")
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(makeupSets) { makeupSet in
                    NavigationLink {
                        MakeupDetail(makeupSet: makeupSet)
                    } label: {
                        CardView(item: makeupSet)
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await fetchMakeup()
        }
    }

    // MARK: - Data Methods

    func fetchMakeup() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var sets: [MakeupSet] = try await supabase.from("makeup_sets")
                .select(MakeupSet.supabaseSelect)
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

            print("✅ Successfully loaded \(sets.count) makeup sets")

            if let user = try? await supabase.auth.session.user {
                sets = await sets.applyingObtainedMakeup(userId: user.id)
            }

            makeupSets = sets

            // Optionally fetch categories if needed for filtering
            do {
                categories = try await supabase.from("makeup_categories")
                    .select("id, slug, title, image_url")
                    .execute()
                    .value

                print("✅ Successfully loaded \(categories.count) categories")
            } catch {
                print("⚠️ Failed to load categories (non-critical): \(error)")
            }

        } catch {
            print("❌ Makeup fetch error:")
            dump(error)
            errorMessage = "Failed to fetch makeup sets: \(error.localizedDescription)"
        }
    }

}
#Preview {
    NavigationStack {
        MakeupView()
    }
}
