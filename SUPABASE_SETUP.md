# Supabase Setup Guide

## 1. Configure Google OAuth Provider

### In Supabase Dashboard:
1. Go to **Authentication** → **Providers**
2. Find **Google** and click to configure
3. Enable the provider
4. Add your Google OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console

### In Google Cloud Console:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable **Google+ API**
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Choose **Android** application type
6. Add package name: `com.rva.kasihustle`
7. Add SHA-1 certificate fingerprint (get from Android Studio or terminal)
8. Add authorized redirect URIs:
   - `https://<your-project>.supabase.co/auth/v1/callback`
   - `com.rva.kasihustle://login-callback`

## 2. Create Profiles Table

Run this SQL in Supabase SQL Editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,
  user_type TEXT CHECK (user_type IN ('hustler', 'business')),
  phone_number TEXT,
  location_name TEXT,
  latitude REAL,
  longitude REAL,
  skills TEXT[], -- for hustlers only
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Create policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Create policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create index for faster lookups
CREATE INDEX profiles_user_type_idx ON profiles(user_type);
CREATE INDEX profiles_location_idx ON profiles(latitude, longitude);
```

## 3. Configure Deep Link in Supabase

### In Supabase Dashboard:
1. Go to **Authentication** → **URL Configuration**
2. Add redirect URLs:
   - `com.rva.kasihustle://login-callback`
3. Add site URL (your app's domain or localhost for development)

## 4. Get SHA-1 Certificate Fingerprint

### For Debug Build:
```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under `Variant: debug` → `Config: debug`

### For Release Build:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 5. Test the Setup

1. **Run the app**: `flutter run`
2. **Click "Sign in with Google"**
3. **Authorize the app** in Google's consent screen
4. **Verify redirect** back to the app
5. **Check logs** for authentication success
6. **Verify profile creation** in Supabase dashboard

## Troubleshooting

### Error: "parse first path segment in URL cannot contain colon"
✅ **Fixed**: Removed `redirectTo` parameter from OAuth call. Supabase Flutter handles this automatically.

### Error: "OAuth redirect URI mismatch"
- Verify redirect URI in Google Cloud Console matches: `https://<your-project>.supabase.co/auth/v1/callback`
- Verify deep link is configured in AndroidManifest.xml
- Verify redirect URL is added in Supabase dashboard

### Error: "Deep link not opening app"
- Check AndroidManifest.xml has the intent filter
- Verify scheme and host match: `com.rva.kasihustle://login-callback`
- Reinstall the app after adding intent filter
- Check Android logs: `adb logcat | grep -i supabase`

### Session not persisting after app restart
- Supabase Flutter automatically handles session persistence
- Check if `authFlowType: AuthFlowType.pkce` is configured in main.dart
- Verify Supabase initialization happens before any auth checks

### Profile not fetching after login
- Check if profiles table exists
- Verify RLS policies allow reading
- Check if AppBloc is listening to auth state changes
- Look for errors in Supabase dashboard → Logs

## Environment Variables

Ensure your `.env` file has:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## Deep Link Testing

Test deep link manually:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "com.rva.kasihustle://login-callback"
```

## Useful Commands

```bash
# Check Android logs for auth issues
adb logcat | grep -E "Supabase|OAuth|Auth"

# Check app package name
adb shell pm list packages | grep kasi

# Clear app data (logout)
adb shell pm clear com.rva.kasihustle

# Reinstall app
flutter run --uninstall-first
```
