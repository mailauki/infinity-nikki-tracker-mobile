//
//  ProfileView+AsyncAvatar.swift
//  Infinity Nikki Tracker
//
//  Alternative avatar implementation using AsyncImage
//  Use this if WebP format causes issues with the current implementation
//

import SwiftUI
import PhotosUI
import Storage
import Supabase

// MARK: - Instructions
// If your avatar still doesn't load after the fix, it might be a WebP format issue.
// Replace the avatar section in ProfileView.swift with this code:

/*

// In ProfileView - replace the avatar Section with this:

Section {
    HStack {
        Group {
            if let avatarURLString = loadedAvatarURL ?? currentAvatarURL,
               let url = URL(string: avatarURLString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical, 20.5)
                            .padding(.horizontal, 21.5)
                            .background(Color.gray)
                            .foregroundStyle(Color.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 20.5)
                    .padding(.horizontal, 21.5)
                    .background(Color.gray)
                    .foregroundStyle(Color.white)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        
        Spacer()
        
        PhotosPicker(selection: $imageSelection, matching: .images) {
            Label("Select a Photo", systemImage: "pencil")
                .labelStyle(.iconOnly)
                .font(.system(size: 25))
                .frame(width: 40, height: 40)
                .foregroundColor(Color.mdOnPrimary)
                .background(Color.mdPrimary)
                .clipShape(Circle())
        }
    }
}

// Add these @State properties at the top of ProfileView:
@State private var currentAvatarURL: String?
@State private var loadedAvatarURL: String?

// Update getInitialProfile to set currentAvatarURL:
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
            currentAvatarURL = profile.avatarURL  // ← Add this line
            
        } catch {
            debugPrint("No existing profile found - user can create one by updating their profile")
        }
        
    } catch {
        errorMessage = "Failed to load user session: \(error.localizedDescription)"
        debugPrint(error)
    }
}

// Update updateProfile to set loadedAvatarURL after upload:
func updateProfile() {
    Task {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let imageURL = try await uploadImage()
            
            if let imageURL {
                loadedAvatarURL = imageURL  // ← Add this line
            }
            
            let currentUser = try await supabase.auth.session.user
            
            let updatedProfile = Profile(
                username: username,
                displayName: displayName,
                avatarURL: imageURL ?? currentAvatarURL
            )
            
            try await supabase
                .from("profiles")
                .update(updatedProfile)
                .eq("id", value: currentUser.id)
                .execute()
                
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            debugPrint(error)
        }
    }
}

*/

// MARK: - Why This Works Better for WebP

/*
 
AsyncImage uses the system's networking and image decoding, which:
 
1. ✅ Handles WebP on iOS 14+ (some support) and iOS 15+ (full support)
2. ✅ Automatic caching
3. ✅ Better memory management
4. ✅ Simpler code
5. ✅ Built-in loading/error states
 
The previous approach downloads to Data and tries to create UIImage,
which doesn't support WebP without additional codecs on older iOS versions.

AsyncImage's URLSession-based approach has better WebP support.

*/

// MARK: - Full Alternative ProfileView Implementation

/*

Here's a complete alternative if you want to replace the whole avatar handling:

struct ProfileView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var imageSelection: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var currentAvatarURL: String?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                // Avatar Section
                Section {
                    HStack {
                        // Display Avatar
                        avatarView
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        Spacer()
                        
                        // Edit Button
                        PhotosPicker(selection: $imageSelection, matching: .images) {
                            Label("Select a Photo", systemImage: "pencil")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 25))
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.mdOnPrimary)
                                .background(Color.mdPrimary)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Rest of your form...
            }
            .onChange(of: imageSelection) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            .task {
                await getInitialProfile()
            }
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        if let selectedImageData,
           let uiImage = UIImage(data: selectedImageData) {
            // Show selected image before upload
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let currentAvatarURL,
                  let url = URL(string: currentAvatarURL) {
            // Show existing avatar
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_), .empty:
                    placeholderAvatar
                @unknown default:
                    placeholderAvatar
                }
            }
        } else {
            // No avatar
            placeholderAvatar
        }
    }
    
    private var placeholderAvatar: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .padding(.vertical, 20.5)
            .padding(.horizontal, 21.5)
            .background(Color.gray)
            .foregroundStyle(Color.white)
    }
    
    func updateProfile() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            
            do {
                var uploadedURL: String? = nil
                
                // Upload new image if selected
                if let imageData = selectedImageData {
                    uploadedURL = try await uploadImage(data: imageData)
                }
                
                let currentUser = try await supabase.auth.session.user
                
                let updatedProfile = Profile(
                    username: username,
                    displayName: displayName,
                    avatarURL: uploadedURL ?? currentAvatarURL
                )
                
                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
                
                // Update current avatar URL if we uploaded a new one
                if let uploadedURL {
                    currentAvatarURL = uploadedURL
                }
                
                // Clear selected image
                selectedImageData = nil
                imageSelection = nil
                
            } catch {
                errorMessage = "Failed to update profile: \(error.localizedDescription)"
                debugPrint(error)
            }
        }
    }
    
    private func uploadImage(data: Data) async throws -> String {
        let currentUser = try await supabase.auth.session.user
        
        // Detect image format
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
        
        try await supabase.storage
            .from("avatars")
            .upload(
                filePath,
                data: data,
                options: FileOptions(
                    contentType: contentType,
                    upsert: true
                )
            )
        
        let publicURL = try supabase.storage
            .from("avatars")
            .getPublicURL(path: filePath)
        
        return publicURL.absoluteString
    }
    
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
                currentAvatarURL = profile.avatarURL
                
            } catch {
                debugPrint("No existing profile found")
            }
            
        } catch {
            errorMessage = "Failed to load user session: \(error.localizedDescription)"
            debugPrint(error)
        }
    }
}

*/
