# Authentication Flow Documentation

## Overview
The app uses **AppBloc** for global authentication state management, integrated with Supabase for authentication and GoRouter for navigation.

## Architecture

### Key Components

1. **AppBloc** (`lib/features/auth/bloc/app_bloc.dart`)
   - Listens to Supabase `onAuthStateChange` stream
   - Manages global authentication state
   - Fetches user profiles from database
   - Handles incomplete profiles by extracting names from Google OAuth

2. **GoRouter** (`lib/core/routing/app_router.dart`)
   - Listens to AppBloc state changes via `GoRouterRefreshStream`
   - Automatically redirects based on authentication status
   - Handles profile completion flow

3. **UserProfileService** (`lib/core/services/user_profile_service.dart`)
   - Singleton service for in-memory user profile caching
   - Updated by AppBloc when auth state changes

## Authentication Flow

### 1. App Startup
```
main.dart
  ├─ Initialize Supabase
  ├─ Create AppBloc (with UserProfileService)
  ├─ Provide AppBloc to widget tree
  └─ Create router with AppBloc.stream listener
```

### 2. Login Flow
```
User clicks "Sign in with Google"
  ↓
AuthRepository.signInWithGoogle()
  ↓
Supabase.auth.signInWithOAuth()
  ↓
Redirect to Google → User authorizes → Redirect back to app
  ↓
Supabase onAuthStateChange fires
  ↓
AppBloc receives AppUserChanged event
  ↓
AppBloc queries profiles table with user.id
  ├─ Profile found → setUser(profile) → authenticated + profileCompleted
  └─ No profile → Split name from Google metadata → authenticated + !profileCompleted
  ↓
GoRouter redirect logic triggers
  ├─ !profileCompleted → Navigate to onboarding
  └─ profileCompleted → Navigate to home/business home
```

### 3. Profile Completion Flow
```
User on onboarding screen (incomplete profile)
  ↓
Complete all onboarding steps
  ↓
OnboardingBloc.CreateProfile event
  ↓
Save to Supabase profiles table
  ↓
UserProfileService.setCurrentUser(profile)
  ↓
AppBloc detects profile in UserProfileService
  ↓
GoRouter redirects to home
```

### 4. Logout Flow
```
User clicks "Logout"
  ↓
context.read<AppBloc>().add(AppLogoutRequested())
  ↓
AppBloc.clearUser()
  ├─ UserProfileService.clearUser()
  └─ Supabase.auth.signOut()
  ↓
Supabase onAuthStateChange fires (session = null)
  ↓
AppBloc receives AppUserChanged(null)
  ↓
AppBloc emits unauthenticated state
  ↓
GoRouter redirects to login screen
```

## State Management

### AppState Properties
- **status**: `unknown | loading | authenticated | unauthenticated`
- **user**: Current user profile (null if not authenticated)
- **profileCompleted**: Whether user has completed onboarding

### AppStatus Flow
```
unknown (initial)
  ↓
loading (auth check in progress)
  ↓
  ├─ authenticated + profileCompleted → Home screen
  ├─ authenticated + !profileCompleted → Onboarding screen
  └─ unauthenticated → Login screen
```

## Router Redirect Logic

### Authentication Check Matrix
| Auth Status | Profile Complete | Current Page | Redirect To |
|-------------|------------------|--------------|-------------|
| unknown/loading | - | any | null (stay) |
| unauthenticated | - | login/verification | null (stay) |
| unauthenticated | - | other | login |
| authenticated | false | onboarding | null (stay) |
| authenticated | false | other | onboarding |
| authenticated | true | login/onboarding/verification | home/business home |
| authenticated | true | other | null (stay) |

## Google OAuth Setup

### Deep Link Configuration
Supabase Flutter handles deep linking automatically. The app uses:
- **Scheme**: `com.rva.kasihustle`
- **Host**: `login-callback`
- **Full Deep Link**: `com.rva.kasihustle://login-callback`

### AndroidManifest.xml Configuration
The deep link intent filter is configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="com.rva.kasihustle"
        android:host="login-callback" />
</intent-filter>
```

### Supabase Initialization
Configured in `main.dart` with PKCE flow:
```dart
await Supabase.initialize(
  url: EnvConfig.supabaseUrl,
  anonKey: EnvConfig.supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

### OAuth Flow
- No `redirectTo` parameter needed in `signInWithOAuth()`
- Supabase automatically handles the redirect to the configured deep link
- App receives the deep link and Supabase session is established

## Database Schema

### Profiles Table (Supabase)
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  first_name TEXT,
  last_name TEXT,
  user_type TEXT, -- 'hustler' or 'business'
  phone_number TEXT,
  location_name TEXT,
  latitude REAL,
  longitude REAL,
  skills TEXT[], -- for hustlers
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Name Extraction Logic

When a user signs in with Google but has no profile:
```dart
// Extract from Google metadata
final fullName = user.userMetadata?['full_name'] ?? '';
final nameParts = fullName.split(' ');
final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

// Pre-fill onboarding
context.go(AppRoutes.onboarding, extra: {
  'firstName': firstName,
  'lastName': lastName,
});
```

## Testing Checklist

- [ ] Fresh install → Shows login screen
- [ ] Google OAuth → Redirects successfully
- [ ] New user → Goes to onboarding with pre-filled name
- [ ] Complete onboarding → Saves profile and goes to home
- [ ] Existing user → Goes directly to home
- [ ] Logout → Clears session and returns to login
- [ ] App restart → Maintains session (or shows login if expired)
- [ ] Profile incomplete → Forces onboarding completion
- [ ] Business user → Goes to business home screen

## Key Files Reference

### Authentication
- `lib/features/auth/bloc/app_bloc.dart` - Global auth state
- `lib/features/auth/bloc/app_event.dart` - Auth events
- `lib/features/auth/bloc/app_state.dart` - Auth state definitions
- `lib/features/auth/domain/repositories/auth_repository.dart` - Supabase OAuth

### Routing
- `lib/core/routing/app_router.dart` - GoRouter with auth redirects
- `lib/main.dart` - AppBloc provider and router initialization

### Services
- `lib/core/services/user_profile_service.dart` - User profile cache

### Screens
- `lib/features/auth/presentation/login_screen.dart` - Login with Google button
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart` - Profile completion

## Environment Setup

Required in `.env`:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Next Steps

1. ✅ **Configure Deep Links**: Deep link intent filter added to AndroidManifest.xml
2. **Create Profiles Table**: Run SQL to create profiles table in Supabase
3. **Configure OAuth Provider in Supabase**: 
   - Go to Supabase Dashboard → Authentication → Providers
   - Enable Google provider
   - Add your Google OAuth Client ID and Secret
   - Add `com.rva.kasihustle://login-callback` to authorized redirect URLs
4. **Test OAuth Flow**: Verify Google sign-in redirects properly to the app
5. **Handle Session Persistence**: Test app restart maintains logged-in state
6. **Error Handling**: Add error states for network failures, OAuth cancellations
