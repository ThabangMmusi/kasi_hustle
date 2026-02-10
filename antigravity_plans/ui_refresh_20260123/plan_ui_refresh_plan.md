# UI Refresh Plan

## Goal Description
Update the UI for Search, Applications, and Profile screens to improve aesthetics and UX, mimicking WhatsApp-like scrolling behavior for the profile and refining colors/layouts.

## User Review Required
- [ ] Confirm "dark brown bt" identification.
- [ ] Confirm "Application" view location.

## Proposed Changes
### Research Phase
- Analyze `HomeScreen` for search and application widgets.
- Analyze `HustlerDrawer` or profile screen.

### Implementation Phase
- **Global Theme Check**: Verify `AppColors.darkSurface` usage and alternatives.

#### [Search Screen](file:///c:/devs/flutter/kasi_hustle/lib/features/search/presentation/screens/search_screen.dart)
- **Goal**: Sticky search box, remove dark background.
- **Changes**:
    -   Replace `Column` with `CustomScrollView`.
    -   Use `SliverToBoxAdapter` for the "Find Your Next Hustle" header.
    -   Use `SliverPersistentHeader` (or `SliverAppBar` pinned) for `StyledTextInput`.
    -   Change background from `AppColors.darkSurface` to `Theme.of(context).colorScheme.surface`.
    -   Update header text colors (from white to `onSurface`).

#### [Applications Screen](file:///c:/devs/flutter/kasi_hustle/lib/features/applications/presentation/screens/applications_screen.dart)
- **Goal**: Remove "Sheet/Stack" look, unify background.
- **Changes**:
    -   Remove `Container` with `AppColors.darkSurface`.
    -   Remove `Expanded` container with rounded top corners.
    -   Make the background uniform (`colorScheme.surface`).
    -   Update text colors in the header ("My Applications", stats) to `onSurface`.

#### [Profile Screen](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/profile_screen.dart)
- **Goal**: Updates layout (Avatar Left, Name Right, Type Bottom) and Scroll Behavior (WhatsApp-like color change).
- **Changes**:
    -   Convert main `Column` to `CustomScrollView` (if not already fully integrated) with `SliverAppBar`.
    -   **SliverAppBar**:
        -   `pinned`: true.
        -   `backgroundColor`: `colorScheme.surface` (light).
        -   `expandedHeight`: ~150-200px.
        -   `flexibleSpace`: `FlexibleSpaceBar` with custom `background`.
    -   **Layout**:
        -   Replace centered Column with a Row in the expanded area (or just below `SliverAppBar` title?).
        -   Row structure: `[Avatar] [HSpace] [Column(Name, Type)]`.
        -   "Type on the bottom": The user means under the Name.
    -   **Scroll Behavior**:
        -   When scrolled up, the `SliverAppBar` should show the Name (and maybe Avatar small).
        -   The background should be light.

## Verification Plan
### Automated Tests
- Run `flutter test` to ensure no regressions in bloc logic.

### Manual Verification
1.  **Search Screen**:
    -   Open Search.
    -   Verify background is NOT dark brown.
    -   Scroll results: Verify "Find Your Next Hustle" scrolls away, but Search Box sticks to top.
2.  **Applications Screen**:
    -   Open "My Applications".
    -   Verify background is uniform (no dark header vs light body curve).
    -   Check Status Cards visibility.
3.  **Profile Screen**:
    -   Open Profile.
    -   Check Layout: Avatar Left, Name to its right, Type below Name.
    -   Scroll: Verify standard SliverAppBar behavior (collapsing).
    -   Check color consistency (Light background).
