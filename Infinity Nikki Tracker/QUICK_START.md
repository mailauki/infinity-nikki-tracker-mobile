# Quick Start: Immediate Improvements

This document outlines the **immediate next steps** you should take after code cleanup to start the mobile migration.

## 🚀 Priority 1: Architecture Foundation (Start Here!)

### 1. Create Service Layer Structure

Create a new folder structure in your project:

```
InfinityNikkiTracker/
├── App/
│   └── ContentView.swift
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignupView.swift
│   │   │   └── WelcomeView.swift
│   │   └── ViewModels/
│   │       └── AuthenticationViewModel.swift
│   ├── Profile/
│   │   ├── Views/
│   │   │   └── ProfileView.swift
│   │   └── ViewModels/
│   │       └── ProfileViewModel.swift
│   └── Eureka/
│       ├── Views/
│       │   ├── EurekaView.swift
│       │   ├── EurekaDetailView.swift
│       │   └── Components/
│       │       ├── EurekaSetRow.swift
│       │       └── EurekaSetCard.swift
│       └── ViewModels/
│           └── EurekaViewModel.swift
├── Services/
│   ├── AuthService.swift
│   ├── ProfileService.swift
│   ├── EurekaService.swift
│   └── ImageService.swift
├── Models/
│   ├── Profile.swift
│   ├── EurekaSet.swift
│   └── AppError.swift
└── Utilities/
    ├── Supabase.swift
    └── Config.swift
```

### 2. Create AppError.swift

```swift
//
//  AppError.swift
//  Infinity Nikki Tracker
//

import Foundation

enum AppError: LocalizedError {
    case networkError(Error)
    case authenticationError(String)
    case dataError(String)
    case imageError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .dataError(let message):
            return "Data error: \(message)"
        case .imageError(let message):
            return "Image error: \(message)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .authenticationError:
            return "Please check your credentials and try again."
        case .dataError:
            return "Please try refreshing the data."
        case .imageError:
            return "Please try uploading the image again."
        case .unknown:
            return "Please try again later."
        }
    }
}
```

### 3. Create AuthService.swift

```swift
//
//  AuthService.swift
//  Infinity Nikki Tracker
//

import Foundation
import Supabase

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func getCurrentUser() async throws -> User
}

final class AuthService: AuthServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = supabase) {
        self.client = client
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            throw AppError.authenticationError(error.localizedDescription)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            try await client.auth.signUp(email: email, password: password)
        } catch {
            throw AppError.authenticationError(error.localizedDescription)
        }
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw AppError.authenticationError(error.localizedDescription)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            throw AppError.authenticationError(error.localizedDescription)
        }
    }
    
    func getCurrentUser() async throws -> User {
        do {
            return try await client.auth.session.user
        } catch {
            throw AppError.authenticationError("No authenticated user")
        }
    }
}
```

### 4. Create EurekaService.swift

```swift
//
//  EurekaService.swift
//  Infinity Nikki Tracker
//

import Foundation
import Supabase

protocol EurekaServiceProtocol {
    func fetchEurekaSets() async throws -> [EurekaSet]
    func fetchCategories() async throws -> [Category]
    func fetchColors() async throws -> [Category]
}

final class EurekaService: EurekaServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = supabase) {
        self.client = client
    }
    
    func fetchEurekaSets() async throws -> [EurekaSet] {
        do {
            return try await client
                .from("eureka_sets")
                .select(
                    """
                    id,
                    slug,
                    title,
                    rarity,
                    style,
                    label,
                    trial,
                    eureka_variants (
                        id,
                        eureka_set,
                        color,
                        category,
                        image_url,
                        default
                    )
                    """
                )
                .order("id", ascending: true, referencedTable: "eureka_variants")
                .execute()
                .value
        } catch {
            throw AppError.dataError(error.localizedDescription)
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        do {
            return try await client
                .from("categories")
                .select("title, image_url")
                .execute()
                .value
        } catch {
            throw AppError.dataError(error.localizedDescription)
        }
    }
    
    func fetchColors() async throws -> [Category] {
        do {
            return try await client
                .from("colors")
                .select("title, image_url")
                .execute()
                .value
        } catch {
            throw AppError.dataError(error.localizedDescription)
        }
    }
}
```

### 5. Create ImageService.swift

```swift
//
//  ImageService.swift
//  Infinity Nikki Tracker
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [URL: Data] = [:]
    private let maxCacheSize = 50 * 1024 * 1024 // 50 MB
    
    func image(for url: URL) -> Data? {
        cache[url]
    }
    
    func cache(data: Data, for url: URL) {
        // Simple cache without size management for now
        cache[url] = data
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

final class ImageService {
    static let shared = ImageService()
    
    private let cache = ImageCache.shared
    
    func loadImage(from url: URL) async throws -> Data {
        // Check cache first
        if let cachedData = await cache.image(for: url) {
            return cachedData
        }
        
        // Download image
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Cache it
        await cache.cache(data: data, for: url)
        
        return data
    }
}

// Helper view for async image loading
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var loadedImage: Image?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let loadedImage {
                content(loadedImage)
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    @MainActor
    private func loadImage() async {
        guard let url = url else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await ImageService.shared.loadImage(from: url)
            
            #if canImport(UIKit)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif canImport(AppKit)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
        } catch {
            print("Failed to load image: \(error)")
        }
    }
}
```

### 6. Create EurekaViewModel.swift

```swift
//
//  EurekaViewModel.swift
//  Infinity Nikki Tracker
//

import Foundation
import Observation

@Observable
final class EurekaViewModel {
    private let service: EurekaServiceProtocol
    
    var eurekaSets: [EurekaSet] = []
    var categories: [Category] = []
    var colors: [Category] = []
    var isLoading = false
    var error: AppError?
    
    // Search and filtering
    var searchText = ""
    var selectedCategory: String?
    var selectedColor: String?
    
    init(service: EurekaServiceProtocol = EurekaService()) {
        self.service = service
    }
    
    var filteredEurekaSets: [EurekaSet] {
        var filtered = eurekaSets
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedCategory {
            filtered = filtered.filter { set in
                set.eurekaVariants.contains { $0.category == selectedCategory }
            }
        }
        
        if let selectedColor {
            filtered = filtered.filter { set in
                set.eurekaVariants.contains { $0.color == selectedColor }
            }
        }
        
        return filtered
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        error = nil
        
        async let setsResult = loadEurekaSets()
        async let categoriesResult = loadCategories()
        async let colorsResult = loadColors()
        
        await setsResult
        await categoriesResult
        await colorsResult
        
        isLoading = false
    }
    
    @MainActor
    private func loadEurekaSets() async {
        do {
            eurekaSets = try await service.fetchEurekaSets()
        } catch let error as AppError {
            self.error = error
        } catch {
            self.error = .unknown
        }
    }
    
    @MainActor
    private func loadCategories() async {
        do {
            categories = try await service.fetchCategories()
        } catch {
            // Categories are optional, don't set error
            print("Failed to load categories: \(error)")
        }
    }
    
    @MainActor
    private func loadColors() async {
        do {
            colors = try await service.fetchColors()
        } catch {
            // Colors are optional, don't set error
            print("Failed to load colors: \(error)")
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedColor = nil
    }
}
```

### 7. Update EurekaView to use ViewModel

```swift
import SwiftUI

struct EurekaView: View {
    @State private var viewModel = EurekaViewModel()
    
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
                    if viewModel.isLoading && viewModel.eurekaSets.isEmpty {
                        ProgressView()
                    }
                }
                .task {
                    await viewModel.loadData()
                }
                .navigationTitle("Eureka")
                .scrollContentBackground(.hidden)
                .background(Color.mdSurface)
                .searchable(text: $viewModel.searchText, prompt: "Search Eureka sets")
                .toolbar {
                    if !viewModel.searchText.isEmpty || 
                       viewModel.selectedCategory != nil || 
                       viewModel.selectedColor != nil {
                        Button("Clear Filters") {
                            viewModel.clearFilters()
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
        List {
            ForEach(viewModel.filteredEurekaSets) { eurekaSet in
                NavigationLink {
                    EurekaDetail(eurekaSet: eurekaSet)
                } label: {
                    EurekaSetRow(eurekaSet: eurekaSet)
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
    
    private var eurekaGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.filteredEurekaSets) { eurekaSet in
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
            await viewModel.loadData()
        }
    }
}
```

## 📝 Immediate Action Items

1. **Create the new file structure** as outlined above
2. **Move existing files** into the appropriate folders
3. **Implement the service layer** (AuthService, EurekaService, ImageService)
4. **Create AppError enum** for better error handling
5. **Refactor EurekaView** to use the new ViewModel pattern
6. **Test** that everything still works

## 🎯 Benefits You'll See Immediately

- ✅ Better separation of concerns
- ✅ Easier to test
- ✅ Reusable components
- ✅ Cleaner view code
- ✅ Centralized error handling
- ✅ Better performance with image caching

## 💡 Next Steps After This

After completing these immediate improvements:

1. Implement Swift Data for offline storage
2. Add comprehensive error states to all views
3. Implement the remaining authentication features
4. Add collection tracking features
5. Optimize for iPad

---

**Note**: If you're using iOS 17+, the `@Observable` macro is available. If targeting iOS 16, use `@StateObject` and `ObservableObject` instead.
