# Enum Syntax Modernization Plan

This plan outlines the steps to modernize the enum syntax across the `kasi_hustle` project, leveraging Dart 3.7+ Enum Shorthands (e.g., using `.start` instead of `CrossAxisAlignment.start`).

## Goal
Update all occurrences of common enums to use the shorthand syntax where the type can be inferred.

## Proposed Changes

### Core UI Components
- Update `lib/core/widgets/` files.
- Update `lib/features/` widgets and screens.

### Target Enums
- `CrossAxisAlignment` -> `.start`, `.center`, `.end`, etc.
- `MainAxisAlignment` -> `.start`, `.center`, `.end`, etc.
- `FontWeight` -> `.w400`, `.bold`, etc.
- `TextAlign` -> `.left`, `.center`, etc.
- `BoxShape` -> `.circle`, `.rectangle`
- `Clip` -> `.none`, `.hardEdge`, etc.

## Verification Plan
1. **Static Analysis**: Run `flutter analyze` to ensure no syntax errors.
2. **Build**: Run a build to ensure the code compiles correctly.
3. **Manual Check**: Verify that the UI remains unchanged in key screens.

## Steps
1. [ ] Confirm SDK version and Enum Shorthand support.
2. [ ] Identify all target enum usages.
3. [ ] Apply shorthand syntax to `lib/core/`.
4. [ ] Apply shorthand syntax to `lib/features/`.
5. [ ] Run `flutter analyze`.
6. [ ] Request final review.
