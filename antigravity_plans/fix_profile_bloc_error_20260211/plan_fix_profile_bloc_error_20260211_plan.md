# Plan: Fix ProfileBloc Provider Error

## Goal
The goal is to resolve the `ProfileBloc` not found error when interacting with a bottom sheet (likely adding a skill) in the Edit Profile screen. The error occurs because the bottom sheet is pushed to a new route and doesn't inherit the `BlocProvider` from the parent context.

## Proposed Changes

### Fix ProfileBloc Context in Bottom Sheet

#### [MODIFY] [edit_profile_screen.dart](file://c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/edit_profile_screen.dart)
- locate the `showModalBottomSheet` call for adding skills.
- Capture the `ProfileBloc` from the parent context.
- Wrap the bottom sheet content in `BlocProvider.value` using the captured bloc.

## Verification Plan

### Manual Verification
- [x] Run the app and navigate to the Profile screen.
- [x] Trigger the action that opens the bottom sheet (e.g., "Add Skill").
- [x] Perform actions inside the bottom sheet (like saving) that previously caused the error.
- [x] Verify that the error is resolved and the skill is added successfully.
