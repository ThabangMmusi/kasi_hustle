# Plan: Implement Stateful Routing

The goal is to preserve the state of the Home Page (including the map) when navigating between different sections of the app. Currently, navigating back to Home triggers a full rebuild and re-initialization of the map, leading to a visible loading state.

## User Review Required

> [!IMPORTANT]
> I will be switching from `ShellRoute` to `StatefulShellRoute` in `go_router`. This is a significant architectural change for navigation but is the standard way to preserve tab state.

## Proposed Changes

### Core Routing

#### [MODIFY] [app_router.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/routing/app_router.dart)
- Replace `ShellRoute` with `StatefulShellRoute.indexedStack`.
- Define branches for Home, Search, Applications, and Menu.
- Use `StatefulNavigationShell` in the `builder` of `StatefulShellRoute`.

### Main Layout

#### [MODIFY] [main_layout.dart](file:///c:/devs/flutter/kasi_hustle/lib/main_layout.dart)
- Update `MainLayout` to accept `StatefulNavigationShell child` instead of `Widget child`.
- Use `child.currentIndex` to determine the selected index.
- Use `child.goBranch(index)` to switch between tabs instead of `context.go()`.
- **New**: When switching to the Search tab, trigger a focus request for the search text field.

### Search Feature

#### [MODIFY] [search_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/search/presentation/screens/search_screen.dart)
- Add a `FocusNode` to `SearchScreenContentState`.
- Implement a mechanism to auto-focus when signaled by `MainLayout` or when the tab becomes active.

### Manual Verification
- Run the app.
- Navigate to the Home page and wait for the map to load.
- Switch to Search, then Applications, then Menu.
- Navigate back to Home and verify that the map is instantly visible without a loading indicator.
- Verify that the map keeps its position/zoom when returning.
