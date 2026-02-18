# Fix Menu Profile Layout

## Goal Description
Fix the layout of the user profile, avatar, and name in `MenuScreen` following the conversion from Row to Column. Ensure proper spacing, sizing, and alignment.

## Proposed Changes
### Menu Feature
#### [MODIFY] [menu_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/menu/presentation/screens/menu_screen.dart)
- Change `HSpace.lg` to `VSpace.med`.
- Remove `Expanded` widget wrapping the text column (it causes layout errors in this context).
- Center text alignment.

## Verification Plan
### Manual Verification
- Run the app.
- Open the Menu.
- Verify the profile section looks correct (centered, proper spacing, no overflow errors).
