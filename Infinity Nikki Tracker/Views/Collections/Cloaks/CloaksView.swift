//
//  CloaksView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import SwiftUI
import Supabase

struct CloaksView: View {
    @State private var cloaks: [MomoCloak] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCloak: MomoCloak?

    @AppStorage("cloaksIsGrid") private var isGrid = true

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
                cloaksGridView
            } else {
                // List Layout View
                cloaksListView
            }
        }
        .overlay {
            if isLoading && cloaks.isEmpty {
                ProgressView()
            }
        }
        .task {
            await fetchCloaks()
        }
        .navigationTitle("Momo's Cloaks")
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
        .sheet(item: $selectedCloak) { cloak in
            DetailCardView(item: cloak)
        }
    }

    // MARK: - View Components

    private var cloaksListView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Cloaks")
            LazyVStack(spacing: 10) {
                ForEach(cloaks) { cloak in
                    Button {
                        selectedCloak = cloak
                    } label: {
                        CardView(item: cloak, layout: .row)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .refreshable {
            await fetchCloaks()
        }
    }

    private var cloaksGridView: some View {
        ScrollView {
            AuthBanner(collectionLabel: "Cloaks")
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cloaks) { cloak in
                    Button {
                        selectedCloak = cloak
                    } label: {
                        CardView(item: cloak)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .refreshable {
            await fetchCloaks()
        }
    }

    // MARK: - Data Methods

    func fetchCloaks() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            var items: [MomoCloak] = try await supabase.from("momo_cloaks")
                .select(MomoCloak.supabaseSelect)
                .order("id", ascending: true)
                .execute()
                .value

            print("✅ Successfully loaded \(items.count) momo cloaks")

            if let user = try? await supabase.auth.session.user {
                items = await items.applyingObtainedMomoCloaks(userId: user.id)
            }

            cloaks = items
        } catch {
            print("❌ Momo cloaks fetch error:")
            dump(error)
            errorMessage = "Failed to fetch cloaks: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        CloaksView()
    }
}
