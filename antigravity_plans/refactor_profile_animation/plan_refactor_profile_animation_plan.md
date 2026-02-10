# Plan: Refactor Profile Shrink Animation

The user wants to improve the "shrink animation" in the Profile Screen. The current implementation uses manual interpolation in a `LayoutBuilder` inside a `SliverAppBar`. While this works, the code is messy, uses manual math for positioning, and results in a "bad" or "imperfect" feel during the transition.

## Analysis of Current Issues
1. **Manual Math**: Deeply nested calculations for `avatarTop`, `avatarLeft`, etc., make the code hard to maintain.
2. **Layout Inefficiency**: Using `Positioned` inside `Stack` within a `background` of a `FlexibleSpaceBar` is a bit unusual; typically, elements that move to the toolbar should be handled more robustly to ensure they line up with the `leading` and `actions` widgets.
3. **Linear Jumps**: Some elements (like the 'Hustler' badge) have hard logic cuts (`if (t > 0.3)`) that can cause flickering or sudden jumps.
4. **Alignment**: The alignment in the collapsed state might not be pixel-perfect with the back button.

## Proposed Changes

### Profile Feature

#### [MODIFY] [profile_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/profile/presentation/screens/profile_screen.dart)
- **Refactor `FlexibleSpaceBar` logic**: Clean up the interpolation math using `lerpDouble` or structured interpolation classes.
- **Improve Layout**:
    - Ensure the avatar and text align perfectly with the `leading` icon in the collapsed state.
    - Use a more consistent easing for the size transitions.
    - Refactor the 'Hustler' badge transition to be smoother (no sudden jumps).
- **Cleanup**: Extract complex sub-widgets if they clutter the `build` method.

## Verification Plan

### Manual Verification
- **Visual Check**: Scroll the profile page and ensure the avatar moves smoothly from center-large to top-left-small.
- **Alignment Check**: In the collapsed state, ensure the name and avatar are vertically centered in the toolbar and horizontally following the back button.
- **Badge Stability**: Ensure the 'Hustler/Job Provider' badge fades or scales smoothly without flickering.
