# Plan: Add Theme Setting on Settings Screen

## Goal
Add a theme setting (Light/Dark/System) to the `SettingsScreen` and persist the user's choice.

## Proposed Changes

### Core Infrastructure
- **[NEW]** `lib/core/bloc/theme/theme_bloc.dart`: Manage `ThemeMode` state.
- **[NEW]** `lib/core/bloc/theme/theme_event.dart`: Define events for changing theme.
- **[NEW]** `lib/core/bloc/theme/theme_state.dart`: Define theme state.
- **[NEW]** `lib/core/services/theme_service.dart`: Persist theme choice in `SharedPreferences`.

### Application Level
- **[MODIFY]** `lib/main.dart`:
    - Provide `ThemeBloc` globally.
    - Use `BlocBuilder<ThemeBloc, ThemeMode>` in `MaterialApp.router` to apply the selected `ThemeMode`.

### UI Changes
- **[MODIFY]** `lib/features/settings/presentation/screens/settings_screen.dart`:
    - Add a "Theme" section above the "Map Settings" section.
    - Use a toggle or a list of options (Light, Dark, System) for theme selection.

## Verification Plan

### Automated Tests
- No automated tests planned for this UI change, will rely on manual verification.

### Manual Verification
1.  Open Settings Screen.
2.  Switch to Dark theme -> Verify UI changes immediately.
3.  Switch to Light theme -> Verify UI changes immediately.
4.  Switch to System theme -> Verify UI follows system settings.
5.  Restart the app -> Verify the last selected theme is persisted and applied on startup.
