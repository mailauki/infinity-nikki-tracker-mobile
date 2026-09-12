# Avatar Loading Debug Guide

## Current Status

The profile page no longer shows the "Object not found" error ✅  
However, the avatar image is not loading 🔍

## Debugging Steps

### Step 1: Check if Avatar Path Exists

When you open the Profile tab, check the console for:

```
🖼️ Attempting to download avatar from path: <some-path>
✅ Downloaded XXXX bytes
✅ Avatar image created successfully
```

**If you see this**: The download is working, but display might be the issue  
**If you don't see this**: The profile doesn't have an avatar_url saved yet

### Step 2: Upload a New Avatar

1. Click the pencil icon on the profile page
2. Select a photo
3. Click "Update profile"
4. Check console for upload messages

### Step 3: Check Supabase Storage

1. Go to Supabase Dashboard
2. Navigate to "Storage" in the left sidebar
3. Click on "avatars" bucket
4. Check if:
   - The bucket exists
   - Files are being uploaded
   - You have proper RLS policies

## Common Avatar Issues

### Issue 1: Storage Bucket Doesn't Exist

**Solution**: Create the bucket in Supabase

```sql
-- In Supabase SQL Editor, create the avatars bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);
```

Or use the Supabase Dashboard:
1. Go to Storage
2. Click "New bucket"
3. Name it "avatars"
4. Make it public (or set up RLS policies)

### Issue 2: Storage RLS Policies Not Set

You need policies for:
- Upload (INSERT)
- Download (SELECT)
- Update
- Delete

**Solution**: Add these policies in Supabase Dashboard (Storage > Policies):

```sql
-- Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow public read access to avatars
CREATE POLICY "Avatars are publicly accessible"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- Allow users to update their own avatars
CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);
```

### Issue 3: Avatar Path Format

The current code saves just the filename:
```swift
let filePath = "\(UUID().uuidString).jpeg"
```

**Better approach** - organize by user:
```swift
let currentUser = try await supabase.auth.session.user
let filePath = "\(currentUser.id)/\(UUID().uuidString).jpeg"
```

This organizes avatars by user ID in folders.

### Issue 4: Image Format Issues

The code forces JPEG format, but the uploaded image might be PNG.

**Better approach**:

```swift
private func uploadImage() async throws -> String? {
    guard let data = avatarImage?.data else { return nil }
    
    let currentUser = try await supabase.auth.session.user
    
    // Detect image format from data
    let imageFormat: String
    if data.starts(with: [0xFF, 0xD8, 0xFF]) {
        imageFormat = "jpeg"
    } else if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
        imageFormat = "png"
    } else {
        imageFormat = "jpeg" // default
    }
    
    let filePath = "\(currentUser.id)/avatar.\(imageFormat)"
    let contentType = "image/\(imageFormat)"
    
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
    
    return filePath
}
```

## Improved Avatar Implementation

Here's a complete improved version:

```swift
private func downloadImage(path: String) async throws {
    print("🖼️ Downloading avatar from: \(path)")
    
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

private func uploadImage() async throws -> String? {
    guard let data = avatarImage?.data else { 
        print("ℹ️ No avatar to upload")
        return nil 
    }
    
    let currentUser = try await supabase.auth.session.user
    
    // Detect format
    let imageFormat: String
    if data.starts(with: [0xFF, 0xD8, 0xFF]) {
        imageFormat = "jpeg"
    } else if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
        imageFormat = "png"
    } else {
        imageFormat = "jpeg"
    }
    
    let filePath = "\(currentUser.id)/avatar.\(imageFormat)"
    let contentType = "image/\(imageFormat)"
    
    print("📤 Uploading avatar to: \(filePath)")
    
    // Delete old avatar if it exists (optional)
    if let oldPath = self.currentAvatarPath {
        try? await supabase.storage
            .from("avatars")
            .remove(paths: [oldPath])
    }
    
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
    
    print("✅ Avatar uploaded successfully")
    return filePath
}

enum ImageError: Error {
    case invalidData
}
```

## Quick Test

1. **Run the app**
2. **Login**
3. **Go to Profile**
4. **Check console** - do you see:
   - `🖼️ Attempting to download avatar from path: ...`
   - Or nothing?

**If nothing**: The profile record doesn't have an avatar_url yet

**If you see download attempt but failure**: Check the error message

**If you see download success but no image**: Issue with AvatarImage creation

## Alternative: Use AsyncImage for Avatars

Instead of downloading to Data, you could use the public URL:

```swift
// In ProfileView
Section {
    HStack {
        if let avatarURL = avatarPublicURL {
            AsyncImage(url: avatarURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(Color.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding()
                .background(Color.gray)
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        }
        
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

// Add computed property
private var avatarPublicURL: URL? {
    guard let avatarPath = currentAvatarPath else { return nil }
    return supabase.storage
        .from("avatars")
        .getPublicURL(path: avatarPath)
}
```

## Next Steps

1. Run the app and check console output
2. Share what you see in the console
3. Meanwhile, share your web app TypeScript types so I can fix the Eureka models
4. Once we have the correct models, everything should work smoothly!
