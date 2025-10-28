# OAuth Error Fix - "parse first path segment in URL cannot contain colon"

## Root Cause
This error occurs because **Supabase's server** is trying to parse the redirect URL and expects a proper HTTP(S) URL format, not a mobile deep link scheme.

## Solution: Configure Redirect URLs in Supabase Dashboard

### Step 1: Add Redirect URL in Supabase Dashboard

1. Go to your **Supabase Dashboard**
2. Select your project
3. Navigate to: **Authentication** → **URL Configuration**
4. In the **Redirect URLs** section, add:
   ```
   io.supabase.kasi_hustle://login-callback
   ```
   
   **Alternative format (if first doesn't work):**
   ```
   com.rva.kasihustle://login-callback
   ```

5. Click **Save**

### Step 2: Update AndroidManifest.xml

Ensure your `android/app/src/main/AndroidManifest.xml` has the correct scheme:

```xml
<!-- Deep linking for Supabase OAuth callback -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Use Supabase's recommended scheme format -->
    <data
        android:scheme="io.supabase.kasi_hustle"
        android:host="login-callback" />
</intent-filter>
```

### Step 3: Alternative - Use HTTP(S) Redirect for Testing

If deep links are not working, you can use an HTTP redirect URL for testing:

1. In Supabase Dashboard → Authentication → URL Configuration, add:
   ```
   https://your-domain.com/auth/callback
   ```

2. For local testing, you can use a temporary URL like:
   ```
   http://localhost:3000/auth/callback
   ```

3. Update your auth code:
   ```dart
   await _supabase.auth.signInWithOAuth(
     OAuthProvider.google,
     redirectTo: 'https://your-domain.com/auth/callback',
   );
   ```

### Step 4: Recommended Approach - Use Supabase's Default Scheme

The best approach is to use Supabase's recommended scheme format:

**Update AndroidManifest.xml:**
```xml
<data android:scheme="io.supabase.kasi_hustle" />
```

**Update auth repository:**
```dart
await _supabase.auth.signInWithOAuth(
  OAuthProvider.google,
  // No redirectTo needed - Supabase will use: io.supabase.<project-ref>://login-callback
);
```

**In Supabase Dashboard, the redirect URL should be:**
```
io.supabase.<your-project-ref>://login-callback
```

Where `<your-project-ref>` is your Supabase project reference (found in your project URL).

## Quick Fix Commands

```bash
# Rebuild the app with new manifest
flutter clean
flutter pub get
flutter run --uninstall-first
```

## Testing the Fix

1. Click "Sign in with Google"
2. Should redirect to Google OAuth
3. After authorization, should redirect back to app
4. Check logs for any errors:
   ```bash
   flutter logs
   ```

## If Still Not Working

### Check Supabase Logs
1. Go to Supabase Dashboard
2. Navigate to **Logs** → **API**
3. Look for the exact error message
4. Check if the redirect URL matches what you configured

### Verify Package Name
Make sure your package name matches in:
- `android/app/build.gradle` → `applicationId`
- AndroidManifest.xml
- Google Cloud Console OAuth credentials

### Check Current Configuration
Run this to see your current Supabase URL:
```dart
print('Supabase URL: ${Supabase.instance.client.auth.currentSession}');
print('Project Ref: ${EnvConfig.supabaseUrl}');
```

## Common Mistakes

❌ **Wrong**: `com.rva.kasihustle://login-callback/` (trailing slash causes issues)  
✅ **Correct**: `io.supabase.kasi_hustle://login-callback`

❌ **Wrong**: Not adding the URL to Supabase Dashboard  
✅ **Correct**: Always add redirect URLs in Dashboard first

❌ **Wrong**: Using app package name as scheme  
✅ **Correct**: Use `io.supabase.<app-name>` format

## Final Working Configuration

### 1. Supabase Dashboard → Authentication → URL Configuration
```
Redirect URLs:
  io.supabase.kasi_hustle://login-callback
```

### 2. AndroidManifest.xml
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.kasi_hustle"
        android:host="login-callback" />
</intent-filter>
```

### 3. auth_repository.dart
```dart
await _supabase.auth.signInWithOAuth(
  OAuthProvider.google,
  authScreenLaunchMode: LaunchMode.externalApplication,
);
```

## Need More Help?

Check Supabase docs: https://supabase.com/docs/guides/auth/social-login/auth-google?platform=flutter
