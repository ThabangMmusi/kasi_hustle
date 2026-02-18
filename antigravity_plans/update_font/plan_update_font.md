# Update Font to Raleway

## Goal Description
Replace "Poppins" font with "Raleway" in `lib/core/theme/styles.dart` as requested by the user. `pubspec.yaml` has already been updated with Raleway font assets.

## Proposed Changes
### Core
#### [MODIFY] [styles.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/theme/styles.dart)
- Update `Fonts` class to replace `poppins` constant with `raleway`.
- Update `TextStyles` class to use `_ralewayBase` instead of `_poppinsBase`.
- Update font family string to "Raleway".

## Verification Plan
### Manual Verification
- Run the app and visually confirm the font change on UI elements using `TextStyles` (e.g. Menu screen, Profile screen).
- Verify no compilation errors.
