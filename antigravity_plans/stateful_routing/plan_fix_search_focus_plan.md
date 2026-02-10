# Plan: Fix Search Auto-Focus Reliability

The goal is to ensure the search field consistently receives focus every time the search tab is selected, including the very first visit and subsequent switches.

## Proposed Changes

### Search Feature

#### [MODIFY] [search_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/search/presentation/screens/search_screen.dart)
- Update `initState` to call `_onFocusRequested()` immediately, ensuring the first-ever navigation to the Search tab is handled (since the listener might be attached after the first request is sent).
- Keep the `300ms` delay to allow for animations and rendering to stabilize.

#### [MODIFY] [main_layout.dart](file:///c:/devs/flutter/kasi_hustle/lib/main_layout.dart)
- (Optional) Ensure `requestFocus` is called reliably. (Already looks okay, but will verify).

## Verification Plan

### Manual Verification
- **Test 1: First Visit**
    - Start the app (default to Home).
    - Tap the **Search** tab for the first time.
    - **Verify**: The keyboard opens and the search field is focused.
- **Test 2: Subsequent Visit**
    - Switch to **Menu** or **Applications**.
    - Switch back to **Search**.
    - **Verify**: The keyboard opens and the search field is focused.
- **Test 3: Double Tap**
    - While on the **Search** screen, tap the **Search** tab again.
    - **Verify**: Focus is maintained or regained.
