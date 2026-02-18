# Refactor Profile: Remove Icons & Fix Keyboard

## Goal Description
1.  **Remove Icons**: Remove the leading icons from "Personal Details", "Primary Skills", and "Additional Skills" interactable sections in `EditProfileScreen`.
2.  **Fix Keyboard Overlap**: Ensure the bottom sheet for editing "Personal Details" (Name/Email/Phone) moves up when the keyboard opens, preventing fields from being hidden.

## Proposed Changes
### Profile Feature
#### [MODIFY] [edit_profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_profile_screen.dart)
- Update `_buildInteractableSection` signature and implementation to remove `icon` parameter and the `Icon` widget in the row.
- Update calls to `_showNameEditBottomSheet`:
    - Ensure `isScrollControlled: true` is set (it is).
    - Add `Padding` to the bottom of the content in the sheet equal to `MediaQuery.of(context).viewInsets.bottom`.
    - Wrap the content in a `SingleChildScrollView` (already there, but ensure valid constraints).
- Update calls to `_buildInteractableSection` to remove the `icon` argument.

## Verification Plan
### Manual Verification
1.  **Icons**: Open "Account Info" screen. Verify icons are gone from "Personal Details", "Primary Skills", and "Additional Skills".
2.  **Keyboard**:
    - Tap "Personal Details".
    - Tap on "Phone Number" or "Email" (bottom fields).
    - Verify the sheet pushes up so the field is visible above the keyboard.
