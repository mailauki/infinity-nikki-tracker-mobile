//
//  ProfileSettingsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/16/26.
//

import PhotosUI
import Supabase
import SwiftUI

struct ProfileSettingsView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var imageSelection: PhotosPickerItem?
    @State private var avatarImage: AvatarImage?
    @State private var errorMessage: String?
    @State private var saveSuccess = false
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Group {
                        if let avatarImage {
                            avatarImage.image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(14)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .frame(width: 64, height: 64)
                    .background(Color.gray)
                    .clipShape(Circle())
                    
                    PhotosPicker(selection: $imageSelection, matching: .images) {
                        Text("Change Photo")
                            .font(.subheadline)
                    }
                }
                .padding(.vertical, 4)
                
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                TextField("Display Name", text: $displayName)
            }
            .foregroundColor(Color.themeOnSurface)
            .listRowBackground(Color.themeSurfaceContainerLowest)
            
            Section {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if saveSuccess {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Profile updated")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Button {
                    updateProfile()
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
            .foregroundColor(Color.themeOnPrimary)
            .listRowBackground(Color.themePrimary)
        }
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            await loadProfile()
        }
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
    }
    
    // MARK: - Methods
    
    private func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let currentUser = try await supabase.auth.session.user
            email = currentUser.email ?? ""
            
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            username = profile.username ?? ""
            displayName = profile.displayName ?? ""
            
            if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                try? await loadAvatar(from: avatarURL)
            }
        } catch {
            // No profile yet — that's fine, fields stay empty
        }
    }
    
    private func updateProfile() {
        Task {
            isSaving = true
            saveSuccess = false
            errorMessage = nil
            defer { isSaving = false }
            do {
                let imageURL = try await uploadImage()
                let currentUser = try await supabase.auth.session.user
                
                struct ProfileUpdate: Encodable {
                    let id: UUID
                    let username: String
                    let displayName: String
                    let avatarURL: String?
                    let updatedAt: String
                    enum CodingKeys: String, CodingKey {
                        case id
                        case username
                        case displayName = "display_name"
                        case avatarURL = "avatar_url"
                        case updatedAt = "updated_at"
                    }
                }
                
                let updates = ProfileUpdate(
                    id: currentUser.id,
                    username: username,
                    displayName: displayName,
                    avatarURL: imageURL,
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase
                    .from("profiles")
                    .upsert(updates, onConflict: "id")
                    .execute()
                
                saveSuccess = true
            } catch {
                errorMessage = "Failed to save: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadTransferable(from item: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await item.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private func loadAvatar(from urlString: String) async throws {
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            guard let url = URL(string: urlString) else { throw URLError(.badURL) }
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = AvatarImage(data: data) else { throw ImageError.invalidData }
            avatarImage = image
        } else {
            let data = try await supabase.storage.from("avatars").download(path: urlString)
            guard let image = AvatarImage(data: data) else { throw ImageError.invalidData }
            avatarImage = image
        }
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        let currentUser = try await supabase.auth.session.user
        let imageFormat = data.starts(with: [0x89, 0x50, 0x4E, 0x47]) ? "png" : "jpeg"
        let contentType = imageFormat == "png" ? "image/png" : "image/jpeg"
        let filePath = "\(currentUser.id)/avatar.\(imageFormat)"
        
        try await supabase.storage
            .from("avatars")
            .upload(filePath, data: data, options: FileOptions(contentType: contentType, upsert: true))
        
        return try supabase.storage.from("avatars").getPublicURL(path: filePath).absoluteString
    }
    
    enum ImageError: Error { case invalidData }
}

#Preview {
    ProfileSettingsView()
}
