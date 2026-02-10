# Changelog: Home Client View Redesign

## Changes
- **2026-01-23**: **Major Refactor**: Split `HomeScreen` (600+ lines) into modular widgets:
    - `HomeMapView`: Isolated map logic and camera animations.
    - `HomeBottomSheet`: Fixed scroll/drag behavior by placing handle bar in `CustomScrollView`.
    - `HomeTopBar`: Encapsulated animated menu and map toggle buttons.
- **2026-01-23**: **Bug Fix**: Resolved issue where the sheet would not drag up from the handle bar.
- **2026-01-23**: **Architecture**: Moved camera animation responsibility from parent screen to `HomeMapView` internal listener for better encapsulation.
