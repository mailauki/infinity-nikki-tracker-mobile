//
//  ProfileView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 1/29/26.
//

import PhotosUI
import Storage
import Supabase
import SwiftUI

struct CollectionItem: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let label: String
}

struct ProfileView: View {
    @State private var email = ""
    @State private var username = "..."
    @State private var displayName = "..."
    @State private var isLoading = false
    @State private var imageSelection: PhotosPickerItem?
    @State private var avatarImage: AvatarImage?
    @State private var errorMessage: String?
    
    @State private var profileCounts: [String] = ["Items", "Following", "Followers"]

    @State private var showStats = false

    var body: some View {
        NavigationStack {
            Group {
                if showStats {
                    StatsView()
                } else {
                    profileContent
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("View", selection: $showStats) {
                        Text("Profile").tag(false)
                        Text("Stats").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }
            }
        }
    }

    private var profileContent: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("@\(username)")
                }
                .font(.system(.headline, weight: .medium))

                Group {
                    if let avatarImage {
                        avatarImage.image
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 20)
                            .padding(.horizontal, 22)
                            .background(Color.gray)
                            .foregroundStyle(Color.white)

                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.horizontal)

                HStack(spacing: 4) {
                    ForEach(profileCounts, id: \.self) { label in // Replace with your data model here
                        VStack {
                            Text("100")
                                .font(.system(.headline, weight: .semibold))
                            Text(label)
                                .font(.footnote)
                        }
                        .frame(width: 80)
                        .clipped()
                    }
                }
                .padding()
                VStack(spacing: 4) {
                    Text(displayName)
                        .font(.headline)
//                    Text("About Me")
//                        .font(.subheadline)
//                        .multilineTextAlignment(.center)
                }
                .frame(width: 250)
                .clipped()
            }
            .frame(maxWidth: .infinity)
            .clipped()
            .padding(.top, 60)
            .padding(.bottom, 150)
        }
        .navigationTitle("Profile")
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .task {
            await getInitialProfile()
        }

    }
    
    // MARK: - Methods
    
    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            email = currentUser.email ?? ""
            
            do {
                let profile: Profile =
                try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: currentUser.id)
                    .single()
                    .execute()
                    .value
                
                username = profile.username ?? ""
                displayName = profile.displayName ?? ""
                
                if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                    do {
                        try await loadAvatar(from: avatarURL)
                        print("✅ Avatar loaded successfully")
                    } catch {
                        print("❌ Failed to load avatar: \(error)")
                        debugPrint(error)
                    }
                }
            } catch {
                // Profile doesn't exist yet - this is OK for new users
                // They'll create it when they first update their profile
                debugPrint("No existing profile found - user can create one by updating their profile")
            }
            
        } catch {
            errorMessage = "Failed to load user session: \(error.localizedDescription)"
            debugPrint(error)
        }
    }
    
    func updateProfile() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                let imageURL = try await uploadImage()
                
                let currentUser = try await supabase.auth.session.user
                
                struct ProfileUpdate: Encodable {
                    let username: String
                    let displayName: String
                    let avatarURL: String?
                    let updatedAt: String
                    
                    enum CodingKeys: String, CodingKey {
                        case username
                        case displayName = "display_name"
                        case avatarURL = "avatar_url"
                        case updatedAt = "updated_at"
                    }
                }
                
                let updates = ProfileUpdate(
                    username: username,
                    displayName: displayName,
                    avatarURL: imageURL,
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase
                    .from("profiles")
                    .update(updates)
                    .eq("id", value: currentUser.id)
                    .execute()
            } catch {
                errorMessage = "Failed to update profile: \(error.localizedDescription)"
                debugPrint(error)
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func loadAvatar(from urlString: String) async throws {
        print("🖼️ Loading avatar from: \(urlString)")
        
        // Check if it's a full URL or just a path
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            // It's a full URL - use AsyncImage approach
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            print("✅ Downloaded \(data.count) bytes from URL")
            
            guard let image = AvatarImage(data: data) else {
                throw ImageError.invalidData
            }
            
            avatarImage = image
            print("✅ Avatar image created successfully")
        } else {
            // It's a storage path - use Supabase storage
            try await downloadImage(path: urlString)
        }
    }
    
    private func downloadImage(path: String) async throws {
        print("🖼️ Downloading avatar from storage path: \(path)")
        
        let data = try await supabase.storage
            .from("avatars")
            .download(path: path)
        
        print("✅ Downloaded \(data.count) bytes")
        
        guard let image = AvatarImage(data: data) else {
            throw ImageError.invalidData
        }
        
        avatarImage = image
        print("✅ Avatar loaded successfully")
    }
    
    enum ImageError: Error {
        case invalidData
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { 
            print("ℹ️ No avatar to upload")
            return nil 
        }
        
        let currentUser = try await supabase.auth.session.user
        
        // Detect image format from data
        let imageFormat: String
        let contentType: String
        
        if data.starts(with: [0xFF, 0xD8, 0xFF]) {
            imageFormat = "jpeg"
            contentType = "image/jpeg"
        } else if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            imageFormat = "png"
            contentType = "image/png"
        } else {
            imageFormat = "jpeg"
            contentType = "image/jpeg"
        }
        
        let filePath = "\(currentUser.id)/avatar.\(imageFormat)"
        
        print("📤 Uploading avatar to: \(filePath)")
        
        try await supabase.storage
            .from("avatars")
            .upload(
                filePath,
                data: data,
                options: FileOptions(
                    contentType: contentType,
                    upsert: true  // Replace existing avatar
                )
            )
        
        print("✅ Avatar uploaded successfully")
        
        // Return the public URL instead of just the path
        let publicURL = try supabase.storage
            .from("avatars")
            .getPublicURL(path: filePath)
        
        return publicURL.absoluteString
    }
}

#Preview {
    ProfileView()
        .environment(AppearanceManager.shared)
}
