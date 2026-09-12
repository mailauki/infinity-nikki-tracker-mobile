# Debug Fixes for Current Issues

## Issues Found

### ✅ Issue 1: Profile "Object not found" Error
**Symptom**: "Failed to load profile: Object not found" appears on Update button

**Root Cause**: New users don't automatically have a profile record in the `profiles` table after signing up.

**Fix Options**:

#### Option A: Create Profile on First Load (Recommended)
Update ProfileView to create a profile if it doesn't exist:

```swift
func getInitialProfile() async {
    do {
        let currentUser = try await supabase.auth.session.user
        email = currentUser.email ?? ""
        
        do {
            // Try to fetch existing profile
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
                try await downloadImage(path: avatarURL)
            }
        } catch {
            // Profile doesn't exist, create an empty one
            let newProfile = Profile(
                username: "",
                displayName: "",
                avatarURL: nil
            )
            
            try await supabase
                .from("profiles")
                .insert(newProfile)
                .eq("id", value: currentUser.id)
                .execute()
        }
        
    } catch {
        errorMessage = "Failed to load profile: \(error.localizedDescription)"
        debugPrint(error)
    }
}
```

#### Option B: Database Trigger (Better long-term solution)
Create a PostgreSQL trigger in Supabase to automatically create profiles:

```sql
-- Run this in Supabase SQL Editor
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, display_name, avatar_url)
  values (new.id, null, null, null);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

---

### ✅ Issue 2: Eureka Page Not Loading
**Symptom**: Eureka page shows empty list or loading spinner indefinitely

**Root Cause**: Field name mismatch in Category model vs database query

**The Problem**:
```swift
// Models.swift expects "name"
struct Category: Codable {
    let name: String
    let imageURL: String
}

// But EurekaView queries "title"
categories = try await supabase.from("categories")
    .select("title, image_url")  // ← Wrong field name!
```

**Fix**: Update the Category model to match your database schema:

```swift
struct Category: Codable {
    let title: String  // Changed from "name" to "title"
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "image_url"
    }
}
```

OR if your database uses "name", update the query:
```swift
categories = try await supabase.from("categories")
    .select("name, image_url")  // Use "name" instead of "title"
```

**Check your database** to see which field name is correct!

---

## Additional Issues to Fix

### Issue 3: Missing CodingKeys in Category
The Category model doesn't have CodingKeys, so it won't properly decode `image_url` to `imageURL`.

**Fix**:
```swift
struct Category: Codable {
    let title: String  // or "name" - match your database
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title  // or "name"
        case imageURL = "image_url"
    }
}
```

---

### Issue 4: EurekaVariant Field Mapping Issue
The `EurekaVariant` model maps `title = "eureka_set"` which seems wrong:

```swift
enum CodingKeys: String, CodingKey {
    case id
    case title = "eureka_set"  // ← This doesn't look right
    case color
    case category
    case imageURL = "image_url"
    case isDefault = "default"
}
```

**Expected**: The `title` should be the variant's title, not the parent set name.

**Fix**: Check your database schema. You might need:
```swift
struct EurekaVariant: Codable, Identifiable {
    let id: Int
    let eurekaSetId: String  // Reference to parent set
    let color: String
    let category: String
    let imageURL: String?
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case eurekaSetId = "eureka_set"
        case color
        case category
        case imageURL = "image_url"
        case isDefault = "default"
    }
}
```

---

## Quick Fixes to Apply Now

### 1. Fix Models.swift
```swift
//
//  Models.swift
//  Infinity Nikki Tracker
//

import Foundation

// MARK: - Profile

struct Profile: Codable {
    let username: String?
    let displayName: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
    }
}

// MARK: - Eureka Models

struct EurekaSet: Codable, Identifiable {
    let id: Int
    let title: String
    let style: String
    let label: String
    let trial: String
    let rarity: Int
    let slug: String
    let eurekaVariants: [EurekaVariant]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case style
        case label
        case trial
        case rarity
        case slug
        case eurekaVariants = "eureka_variants"
    }
}

struct EurekaVariant: Codable, Identifiable {
    let id: Int
    let eurekaSetId: String  // The name/reference of the parent set
    let color: String
    let category: String
    let imageURL: String?
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case eurekaSetId = "eureka_set"
        case color
        case category
        case imageURL = "image_url"
        case isDefault = "default"
    }
}

struct Category: Codable {
    let title: String  // ← Changed from "name" to match your query
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "image_url"
    }
}
```

### 2. Fix EurekaRow.swift
Since we changed `title` to `eurekaSetId`:
```swift
struct EurekaRow: View {
    var eurekaVariant: EurekaVariant
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "\(eurekaVariant.imageURL ?? "")")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .frame(width: 60, height: 40)
                        .foregroundStyle(.placeholder.opacity(0.5))
                } else {
                    ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading) {
                // You might want to display the variant's category/color instead
                // since the actual title comes from the parent EurekaSet
                Text("\(eurekaVariant.category) - \(eurekaVariant.color)")
                    .font(.headline)
                    .foregroundStyle(Color.mdOnSurface)
                
                Text(eurekaVariant.eurekaSetId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            CheckToggle(label: "Obtained", isChecked: eurekaVariant.isDefault)
        }
    }
}
```

### 3. Update ProfileView.swift for Profile Creation
Add this updated method:

```swift
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
                try await downloadImage(path: avatarURL)
            }
        } catch {
            // Profile doesn't exist - this is OK for new users
            // They'll create it when they update their profile
            debugPrint("No existing profile found, user can create one by updating")
        }
        
    } catch {
        errorMessage = "Failed to load profile: \(error.localizedDescription)"
        debugPrint(error)
    }
}
```

---

## Testing Checklist

After applying fixes:

- [ ] Login with existing account
- [ ] Check if profile loads without error
- [ ] Update profile information
- [ ] Sign out and create new account
- [ ] Verify new account can update profile
- [ ] Navigate to Eureka tab
- [ ] Verify Eureka sets load
- [ ] Open an Eureka detail page
- [ ] Verify variants display correctly
- [ ] Check console for any remaining errors

---

## Database Schema Verification

You should verify your Supabase tables match these expectations:

### profiles table
```sql
id (uuid, primary key)
username (text, nullable)
display_name (text, nullable)
avatar_url (text, nullable)
created_at (timestamp)
updated_at (timestamp)
```

### eureka_sets table
```sql
id (int, primary key)
title (text)
slug (text)
style (text)
label (text)
trial (text)
rarity (int)
```

### eureka_variants table
```sql
id (int, primary key)
eureka_set (text or int - reference to eureka_sets)
color (text)
category (text)
image_url (text, nullable)
default (boolean)
```

### categories table
```sql
title (text) OR name (text) - CHECK WHICH ONE YOU HAVE!
image_url (text)
```

---

## Next Steps

1. **Check your database schema** in Supabase
2. **Apply the model fixes** to match your actual schema
3. **Test profile creation** flow
4. **Test Eureka loading** flow
5. **Add database trigger** for automatic profile creation (recommended)
6. **Add better error messages** to help debug in the future

---

## Pro Tips

1. **Enable Detailed Logging**: Add this to see full Supabase errors:
```swift
func fetchEureka() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    
    do {
        eurekaSets = try await supabase
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
        
        print("✅ Successfully loaded \(eurekaSets.count) eureka sets")
        
    } catch {
        print("❌ Eureka fetch error:")
        dump(error)  // This gives you detailed error info
        errorMessage = "Failed to fetch eureka sets: \(error.localizedDescription)"
    }
}
```

2. **Test Queries in Supabase Dashboard**: Before coding, test your queries in the Supabase SQL editor to ensure field names are correct.

3. **Use Proper Error Types**: Consider creating custom error types to better handle specific Supabase errors.
