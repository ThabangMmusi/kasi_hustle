# Refactor Menu and Profile

## Goal Description
1.  **Menu Animation**: Animate `MenuScreen` entrance from the bottom (like a bottom sheet).
2.  **Profile Titles**:
    *   Rename "Personal Information" menu item to "Manage Account".
    *   Rename "Edit Profile" screen title to "Account Info".
3.  **Name Editing**:
    *   Extract name editing (First/Last) to a separate bottom sheet/view.
    *   Style it consistently with the Skills selection (same color as container).

## Proposed Changes
### Routing
#### [MODIFY] [app_router.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/routing/app_router.dart)
- Change `MenuScreen` route builder to `CustomTransitionPage` with `SlideTransition` from bottom (Offset 0, 1 -> 0, 0).

### Menu Feature
#### [MODIFY] [menu_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/menu/presentation/screens/menu_screen.dart)
- Update label "Personal Information" to "Manage Account".

### Profile Feature
#### [MODIFY] [edit_profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_profile_screen.dart)
- Change AppBar title to "Account Info".
- Remove direct `StyledTextInput` fields for Name.
- Add "Personal Details" section (or similar) using `_buildInteractableSection` pattern.
- Implement `_showNameEditBottomSheet` styled like `_showPrimarySkillsBottomSheet`.
- Ensure buttons and container styles match the request (light primary container color).

## Verification Plan
### Manual Verification
1.  **Menu Animation**: Tap "Menu" tab. Verify it slides up from bottom.
2.  **Titles**: Verify "Manage Account" in Menu and "Account Info" in Edit Profile screen.
3.  **Name Editing**:
    *   Tap "Personal Details" (or Name section).
    *   Verify bottom sheet opens.
    *   Verify styling matches Skills sheet.
    *   Edit name and save.
    *   Verify changes reflect in Profile.
