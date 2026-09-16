//
//  SettingsView.swift
//  Infinity Nikki Tracker
//
//  Created by Julie Evans on 9/11/26.
//

import PhotosUI
import Supabase
import SwiftUI

struct SettingsView: View {
    @Environment(AppearanceManager.self) private var appearanceManager

    @State private var email = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var imageSelection: PhotosPickerItem?
    @State private var avatarImage: AvatarImage?
    @State private var errorMessage: String?
    @State private var saveSuccess = false

    @State private var sortOrder: DefaultSortOrder = .newest
    @State private var isLoadingPreferences = false
    @State private var preferencesError: String?

    @State private var newEmail = ""
    @State private var isUpdatingEmail = false
    @State private var emailError: String?
    @State private var emailSuccess = false

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isUpdatingPassword = false
    @State private var passwordError: String?
    @State private var passwordSuccess = false

    @State private var showDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var deleteAccountError: String?

    var body: some View {
        List {
            Section {
                NavigationLink("Profile") {
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
                NavigationLink("Appearance") {
                    List {
                        modeSection
                        textScaleSection
                        sortOrderSection
                        colorThemeSection
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.themeSurface)
                    .disabled(isLoadingPreferences)
                    .overlay {
                        if isLoadingPreferences {
                            ProgressView()
                        }
                    }
                    .task {
                        await loadPreferences()
                    }
                    .onChange(of: appearanceManager.theme) { _, _ in
                        guard !isLoadingPreferences else { return }
                        updatePreferences()
                    }
                    .onChange(of: appearanceManager.textScale) { _, _ in
                        guard !isLoadingPreferences else { return }
                        updatePreferences()
                    }
                    .onChange(of: appearanceManager.colorTheme) { _, _ in
                        guard !isLoadingPreferences else { return }
                        updatePreferences()
                    }
                    .onChange(of: sortOrder) { _, _ in
                        guard !isLoadingPreferences else { return }
                        updatePreferences()
                    }
                    .alert(
                        "Couldn't Save Appearance",
                        isPresented: Binding(
                            get: { preferencesError != nil },
                            set: { if !$0 { preferencesError = nil } }
                        )
                    ) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(preferencesError ?? "")
                    }
                }
                NavigationLink("Account") {
                    List {
                        Section("Change Email") {
                            TextField("New Email", text: $newEmail)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)

                            if let emailError {
                                Text(emailError)
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }

                            if emailSuccess {
                                Text("Check your inbox to confirm the new email")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            }

                            Button {
                                updateEmail()
                            } label: {
                                if isUpdatingEmail {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Update Email")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundColor(Color.themePrimary)
                            .disabled(isUpdatingEmail || newEmail.isEmpty)
                        }
                        .foregroundColor(Color.themeOnSurface)
                        .listRowBackground(Color.themeSurfaceContainerLowest)

                        Section("Change Password") {
                            SecureField("New Password", text: $newPassword)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.newPassword)

                            SecureField("Confirm Password", text: $confirmPassword)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.newPassword)

                            if let passwordError {
                                Text(passwordError)
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }

                            if passwordSuccess {
                                Text("Password updated")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            }

                            Button {
                                updatePassword()
                            } label: {
                                if isUpdatingPassword {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Update Password")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundColor(Color.themePrimary)
                            .disabled(isUpdatingPassword || newPassword.isEmpty || confirmPassword.isEmpty)
                        }
                        .foregroundColor(Color.themeOnSurface)
                        .listRowBackground(Color.themeSurfaceContainerLowest)

                        Section("Connected Accounts") {
                            Text("TDB")
                        }
                        .foregroundColor(Color.themeOnSurface)
                        .listRowBackground(Color.themeSurfaceContainerLowest)

                        Section("Danger Zone") {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                if isDeletingAccount {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Delete Account")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .fontWeight(.bold)
                            .foregroundColor(Color.themeOnError)
                            .listRowBackground(Color.themeError)
                            .disabled(isDeletingAccount)
                        }
                        .foregroundColor(Color.themeOnSurface)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.themeSurface)
                    .confirmationDialog(
                        "Delete Account?",
                        isPresented: $showDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete Account", role: .destructive) {
                            deleteAccount()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This permanently deletes your account and all of your saved progress. This can't be undone.")
                    }
                    .alert(
                        "Couldn't Delete Account",
                        isPresented: Binding(
                            get: { deleteAccountError != nil },
                            set: { if !$0 { deleteAccountError = nil } }
                        )
                    ) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(deleteAccountError ?? "")
                    }
                }
            }
            .foregroundColor(Color.themeOnSurface)
            .listRowBackground(Color.themeSurfaceContainerLowest)
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(Color.themeSurface)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign Out", systemImage: "iphone.and.arrow.right.outward") {
                    Task { try? await supabase.auth.signOut() }
                }
            }
        }
    }

    // MARK: - Appearance Sections

    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { appearanceManager.theme },
            set: { appearanceManager.theme = $0 }
        )
    }

    private var textScaleBinding: Binding<TextScale> {
        Binding(
            get: { appearanceManager.textScale },
            set: { appearanceManager.textScale = $0 }
        )
    }

    private var modeSection: some View {
        Section("Mode") {
            Picker("Mode", selection: themeBinding) {
                ForEach(ThemeMode.allCases) { mode in
                    SwiftUI.Label(mode.label, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }

    private var textScaleSection: some View {
        Section {
            Picker("Text Size", selection: textScaleBinding) {
                ForEach(TextScale.allCases) { scale in
                    Text(scale.label)
                        .tag(scale)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Text Size")
        } footer: {
            Text("Scales text across the whole app, including collection grids and filters.")
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }

    private var sortOrderSection: some View {
        Section {
            Picker("Default Sort", selection: $sortOrder) {
                ForEach(DefaultSortOrder.allCases) { order in
                    Text(order.label)
                        .tag(order)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        } header: {
            Text("Default Sort")
        } footer: {
            Text("Applies to the Eureka and Outfits collection views.")
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }

    private var colorThemeSection: some View {
        Section("Color Theme") {
            ForEach(ColorTheme.allCases) { option in
                Button {
                    appearanceManager.colorTheme = option
                } label: {
                    ThemePickerCard(title: option.title, subtitle: option.subtitle, isSelected: appearanceManager.colorTheme == option)
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundColor(Color.themeOnSurface)
        .listRowBackground(Color.themeSurfaceContainerLowest)
    }

    struct ThemePickerCard: View {
        let title: String
        let subtitle: String
        var isSelected: Bool = false

        var body: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Circle().fill(Color("Theme/\(title)/Primary/Main"))
                            .frame(width: 20)
                        Circle().fill(Color("Theme/\(title)/Secondary/Main"))
                            .frame(width: 20)
                        Circle().fill(Color("Theme/\(title)/Tertiary/Main"))
                            .frame(width: 20)
                    }
                    Text(title)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(Color.themeOnSurfaceVariant)
                }
                Spacer()
                CheckToggle(isChecked: isSelected)
            }
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

    private func loadPreferences() async {
        isLoadingPreferences = true
        defer { isLoadingPreferences = false }
        if let preferences = await appearanceManager.load() {
            sortOrder = preferences.sortOrder ?? .newest
        }
    }

    private func updatePreferences() {
        Task {
            preferencesError = nil
            do {
                let currentUser = try await supabase.auth.session.user

                struct PreferencesUpdate: Encodable {
                    let userId: UUID
                    let theme: String
                    let colorTheme: String
                    let sortOrder: String
                    let textScale: String
                    let updatedAt: String
                    enum CodingKeys: String, CodingKey {
                        case userId = "user_id"
                        case theme
                        case colorTheme = "color_theme"
                        case sortOrder = "sort_order"
                        case textScale = "text_scale"
                        case updatedAt = "updated_at"
                    }
                }

                let updates = PreferencesUpdate(
                    userId: currentUser.id,
                    theme: appearanceManager.theme.rawValue,
                    colorTheme: appearanceManager.colorTheme.rawValue,
                    sortOrder: sortOrder.rawValue,
                    textScale: appearanceManager.textScale.rawValue,
                    updatedAt: ISO8601DateFormatter().string(from: Date())
                )

                try await supabase
                    .from("user_preferences")
                    .upsert(updates, onConflict: "user_id")
                    .execute()
            } catch {
                preferencesError = "Failed to save: \(error.localizedDescription)"
            }
        }
    }

    private func updateEmail() {
        Task {
            isUpdatingEmail = true
            emailSuccess = false
            emailError = nil
            defer { isUpdatingEmail = false }
            do {
                try await supabase.auth.update(user: UserAttributes(email: newEmail))
                emailSuccess = true
                newEmail = ""
            } catch {
                emailError = "Failed to update email: \(error.localizedDescription)"
            }
        }
    }

    private func updatePassword() {
        guard newPassword == confirmPassword else {
            passwordError = "Passwords don't match"
            return
        }
        Task {
            isUpdatingPassword = true
            passwordSuccess = false
            passwordError = nil
            defer { isUpdatingPassword = false }
            do {
                try await supabase.auth.update(user: UserAttributes(password: newPassword))
                passwordSuccess = true
                newPassword = ""
                confirmPassword = ""
            } catch {
                passwordError = "Failed to update password: \(error.localizedDescription)"
            }
        }
    }

    private func deleteAccount() {
        Task {
            isDeletingAccount = true
            deleteAccountError = nil
            defer { isDeletingAccount = false }
            do {
                try await supabase.rpc("delete_user").execute()
                try await supabase.auth.signOut()
            } catch {
                deleteAccountError = "Failed to delete account: \(error.localizedDescription)"
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
    NavigationStack {
        SettingsView()
    }
    .environment(AppearanceManager.shared)
}
