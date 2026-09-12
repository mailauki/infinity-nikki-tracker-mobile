# Testing Guide - Debug Fixes

## What Was Fixed

### ✅ Fixed Issue 1: Profile Loading Error
**Changed**: ProfileView now handles missing profiles gracefully
- Won't show error if profile doesn't exist (common for new users)
- User can still update profile to create it
- Email still loads from auth session

### ✅ Fixed Issue 2: Data Model Mismatches
**Changed**: Updated models to match database schema
- `Category.title` instead of `Category.name` (with proper CodingKeys)
- `EurekaVariant.eurekaSetName` instead of `title` for clarity
- Added missing CodingKeys to all models

### ✅ Added Better Error Logging
**Changed**: EurekaView now logs detailed fetch information
- Shows how many items loaded successfully
- Dumps full error details for debugging
- Easier to identify what's failing

---

## Testing Steps

### Test 1: Profile View
1. **Run the app** in simulator
2. **Login** with existing account
3. **Go to Profile tab**
4. **Check console** - should NOT see "Failed to load profile" error anymore
5. **Try updating profile** (change username or display name)
6. **Check** if update succeeds

**Expected Results:**
- ✅ No error message on profile page
- ✅ Email displays correctly
- ✅ Can update username/display name
- ✅ Updates persist after navigation

---

### Test 2: Eureka List Loading
1. **Go to Eureka tab**
2. **Watch console output** for these messages:
   - `✅ Successfully loaded X eureka sets`
   - `✅ Successfully loaded X categories`
   - `✅ Successfully loaded X colors`

3. **If you see errors**, check the console output carefully

**Expected Results:**
- ✅ Console shows successful load messages
- ✅ Eureka list populates with items
- ✅ Images load (or show placeholder)
- ✅ Rarity stars display
- ✅ Labels/chips display

---

### Test 3: Eureka Detail View
1. **Tap on any Eureka set** from the list
2. **Check detail page loads**
3. **Verify variants display** correctly

**Expected Results:**
- ✅ Detail view opens
- ✅ Header shows set name, rarity, style, trial
- ✅ Variants list shows category and color info
- ✅ Images load properly

---

## Troubleshooting

### If Eureka Still Doesn't Load

**Check Console Output for Errors**

Look for one of these error patterns:

#### Error Pattern 1: "Column not found" or "relation does not exist"
```
❌ PostgrestError: column "title" does not exist
```

**Solution**: Your database uses different field names. Check Supabase dashboard:
1. Go to Table Editor
2. Look at `categories` table
3. See if it uses `name` or `title`
4. Update the query in EurekaView.swift to match

#### Error Pattern 2: "Failed to decode"
```
❌ DecodingError: keyNotFound
```

**Solution**: Field name mismatch between model and database
1. Check the specific field mentioned in error
2. Compare to your Supabase schema
3. Update CodingKeys in Models.swift

#### Error Pattern 3: No error but empty list
**Possible Causes:**
- Database is actually empty (check Supabase dashboard)
- RLS (Row Level Security) blocking reads
- Wrong table name

**Solution**: Check Supabase Dashboard
1. Go to Table Editor
2. Verify `eureka_sets` table has data
3. Check RLS policies (Authentication > Policies)
4. Temporarily disable RLS for testing (don't forget to re-enable!)

---

## Common Database Schema Issues

### If your database uses different field names:

#### For Categories Table

**If using "name" instead of "title":**

Update EurekaView.swift:
```swift
categories = try await supabase.from("categories")
    .select("name, image_url")  // Changed "title" to "name"
    .execute()
    .value
```

And update Models.swift:
```swift
struct Category: Codable {
    let name: String  // Changed from "title"
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
    }
}
```

#### For Colors Table
Same pattern - check if it's "name" or "title" and adjust accordingly.

---

## Database Setup Verification

### Check Your Supabase Tables

Run these queries in Supabase SQL Editor:

```sql
-- Check if eureka_sets table has data
SELECT COUNT(*) FROM eureka_sets;

-- Check first few rows
SELECT * FROM eureka_sets LIMIT 5;

-- Check eureka_variants
SELECT COUNT(*) FROM eureka_variants;

-- Check categories
SELECT * FROM categories LIMIT 5;

-- Check colors
SELECT * FROM colors LIMIT 5;
```

### Check RLS Policies

For each table, you should have read policies that allow authenticated users:

```sql
-- Example RLS policy for eureka_sets
CREATE POLICY "Enable read access for authenticated users" ON eureka_sets
    FOR SELECT
    TO authenticated
    USING (true);

-- Do the same for:
-- eureka_variants, categories, colors, profiles
```

---

## Profile Creation for New Users

### Option A: Manual Profile Creation (Current)
When user first updates profile, it creates the record.

### Option B: Automatic Profile Creation (Recommended)

Add this SQL trigger in Supabase:

```sql
-- Function to create profile for new user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, display_name, avatar_url, created_at, updated_at)
  VALUES (NEW.id, NULL, NULL, NULL, NOW(), NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**Note**: This assumes your profiles table has:
- `id` (uuid, references auth.users)
- `username` (text, nullable)
- `display_name` (text, nullable)
- `avatar_url` (text, nullable)
- `created_at` (timestamp)
- `updated_at` (timestamp)

---

## Success Criteria

After testing, you should have:

- [x] Profile page loads without errors
- [x] Can update profile successfully
- [x] Eureka list loads and displays items
- [x] Can navigate to detail views
- [x] Console shows success messages, not errors
- [x] Images load (or show appropriate placeholders)

---

## Next Steps After Successful Testing

Once everything works:

1. ✅ **Remove or reduce console logging** (keep only important logs)
2. ✅ **Add the database trigger** for automatic profile creation
3. ✅ **Start Phase 1** of the migration plan (Service Layer)
4. ✅ **Implement proper error UI** (not just console logs)
5. ✅ **Add loading states** with better UX

---

## Quick Console Log Cleanup

After testing, you can reduce verbose logging:

```swift
// In EurekaView.swift - replace the detailed logging with:
print("Loaded \(eurekaSets.count) sets, \(categories.count) categories, \(colors.count) colors")

// Or remove completely for production
```

---

## Need More Help?

If you're still having issues:

1. **Check the full error dump** in console
2. **Screenshot your Supabase table schema**
3. **Verify your Row Level Security policies**
4. **Check if you're using the correct Supabase URL/key**
5. **Make sure you're testing with the latest code changes**

The detailed console logs should now give you much better information about what's failing!
