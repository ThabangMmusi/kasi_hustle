# Custom Map Markers Implementation Plan

## Goal
Replace default red/orange map markers with a custom "briefcase" icon (`Ionicons.briefcase`) colored with the app's primary color, as requested by the user.

## Proposed Changes

### Core Assets/Utils
#### [NEW] [map_marker_helper.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/utils/map_marker_helper.dart)
- Create a utility function `getBytesFromCanvas` or `getCustomMarkerBitmap`.
- Input: `int width`, `int height`, `IconData icon`, `Color color`.
- Logic:
    1. Create `PictureRecorder` and `Canvas`.
    2. Draw a circle (Primary Color) with the Briefcase Icon (OnPrimary Color) inside.
    3. `TextPainter` to draw the icon.
    4. Convert to PNG bytes.
    5. Return `Uint8List`.

### Home Feature
#### [MODIFY] [home_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/screens/home_screen.dart)
- Add state variable `BitmapDescriptor? _customMarkerIcon`.
- Add method `_loadCustomMarker()`:
    - Get `colorScheme.primary` and `colorScheme.onPrimary`.
    - Call helper to generate bytes.
    - `BitmapDescriptor.fromBytes(...)`.
- Call `_loadCustomMarker()` in `didChangeDependencies` (to access Theme safely).
- Update `_updateMarkers` to use `_customMarkerIcon`.

## Verification Plan

### Manual Verification
1.  **Hot Restart**: Ensure the new code runs from fresh state.
2.  **Visual Check**:
    - Verify markers are **Primary Color** with **Briefcase Icon**.
    - Verify positioning and timing.
