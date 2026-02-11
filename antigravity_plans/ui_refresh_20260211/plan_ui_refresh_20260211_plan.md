# Profile and Edit Profile UI Refresh Plan

## Goal Description
Refactor functionality between Profile Screen and Edit Profile Screen to improve UX.
- Move Skill editing to Profile Screen with instant updates.
- Remove Bio editing from Edit Profile (keep in Profile Screen with instant update).
- Refactor Edit Profile to "Auto-save on exit".
- Update Edit Profile UI: Add Email/Phone, Verification status, Move SignOut/Delete to a "More" menu.

## User Review Required
> [!IMPORTANT]
> - "Auto-save on exit" implies that we will trigger the API call when the user navigates away. If the API call fails, the user might not know since they have already left the screen. We might need a global snackbar or handling to inform them if it fails *after* they leave, or block exit until save completes (but "exit" usually implies immediate navigation).
> - I will implement `PopScope` to trigger the save.
> - Email update usually requires re-verification in many apps, but I will implement it as a direct update for now as per instructions.

## Proposed Changes

### Profile Feature

#### [MODIFY] [profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/profile_screen.dart)
- Make "Primary Skills" and "Additional Skills" sections interactable.
- Implement/Move `_showPrimarySkillsBottomSheet` and `_showSecondarySkillsBottomSheet` from `EditProfileScreen`.
- Ensure "Apply" in these sheets triggers `UpdateProfile` event immediately.

#### [MODIFY] [edit_profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_profile_screen.dart)
- Remove `_bioController`, `_primarySkills`, `_secondarySkills` logic/UI.
- Remove "Save Changes" button.
- Add `_emailController` and `_phoneController`.
- Wrap `Scaffold` in `PopScope` to intercept back navigation.
  - On pop: Check if changes exist. If yes, dispatch `UpdateProfile` event.
- Add `AppBar` action: "More" icon (`Ionicons.ellipsis_vertical`).
  - Opens BottomSheet with "Sign Out" and "Delete Account".
- Remove "Sign Out" and "Delete Account" buttons from the main body.
- Add Verification Badge logic (next to name/photo?).
  - If verified: Show Badge.
  - If not verified: Show "Verify Now" button (placeholder action or navigation).

## Verification Plan

### Automated Tests
- None specified.

### Manual Verification
1. **Skills on Profile Screen**:
   - Tap "Primary Skills" -> Change -> Apply -> Verify UI updates instantly.
   - Tap "Additional Skills" -> Change -> Apply -> Verify UI updates instantly.
2. **Bio on Profile Screen**:
   - Edit Bio -> Save -> Verify UI updates instantly.
3. **Edit Profile Screen**:
   - Verify Skills and Bio are GONE.
   - Verify Email and Phone fields are present and populated.
   - Change Name/Email/Phone -> Go Back -> Verify Profile Screen shows new data (might need to wait for API update or optimistic update).
   - Check "More" menu -> Verify "Sign Out" and "Delete Account" options appear and work.
   - Check Verification Badge/Button appearance.
