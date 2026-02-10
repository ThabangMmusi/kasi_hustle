# Changelog: Refactor Menu Item to Centralized Widget

## [2026-01-26]
- Created `StandardMenuItem` widget in `lib/core/widgets/standard_menu_item.dart`.
- Refactored `MenuScreen` to use `StandardMenuItem`.
- Refactored `HustlerDrawer` to use `StandardMenuItem`.
- Removed local `_MenuItem` and `_DrawerItem` classes.
