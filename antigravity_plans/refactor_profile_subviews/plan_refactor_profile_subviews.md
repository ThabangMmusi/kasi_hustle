# Refactor Profile Editing: Separate Views (Names & Contacts)

## Goal Description
Refactor the profile editing flow to replace the combined bottom-sheet editor with separate, full-screen navigations for "Names" and "Contacts". Each sub-view will feature an "X" button to cancel and a "Done" button at the bottom to save.

## User Review Required
> [!IMPORTANT]
> The "Names" and "Contacts" sections will now navigate to separate screens instead of opening a bottom sheet.

## Proposed Changes

### Routing
#### [MODIFY] [app_router.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/routing/app_router.dart)
- Add `editNames` and `editContacts` paths to `AppRoutes`.
- Add sub-routes for `EditNamesScreen` and `EditContactsScreen` under `/profile` (or as separate top-level routes if preferred by design, but sub-routes are cleaner for hierarchy).

### Profile Feature
#### [MODIFY] [edit_names_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_names_screen.dart)
- Set `autofocus: true` on the First Name text input.
- Apply dynamic bottom padding to the "Done" button container using `MediaQuery.of(context).viewPadding.bottom` and `MediaQuery.of(context).viewInsets.bottom` (if necessary for manual control) to ensure it stays above the keyboard and safe area.

#### [MODIFY] [edit_contacts_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_contacts_screen.dart)
- Set `autofocus: true` on the Email Address text input.
- Apply similar dynamic bottom padding to the "Done" button container.

#### [MODIFY] [edit_profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_profile_screen.dart)
- Replace "Personal Details" section with two separate sections: "Names" and "Contacts".
- "Names" section will display the user's full name.
- "Contacts" section will display email and phone number.
- Update `onTap` handlers to navigate to the new screens.
- Remove `_showNameEditBottomSheet` and related logic.

## Verification Plan
### Manual Verification
1.  **Navigation**: Open the "Account Info" screen and verify two separate sections for "Names" and "Contacts".
2.  **Edit Names**:
    - Tap "Names". Change first/last name.
    - Click "Done". Verify the change is reflected on the main profile screen.
    - Click "X". Verify the change is discarded.
3.  **Edit Contacts**:
    - Tap "Contacts". Change email/phone.
    - Click "Done". Verify changes.
    - Click "X". Verify discard.
4.  **UI Consistency**: Ensure both new screens follow the styling of `EditProfileScreen` (typography, margins, buttons).
