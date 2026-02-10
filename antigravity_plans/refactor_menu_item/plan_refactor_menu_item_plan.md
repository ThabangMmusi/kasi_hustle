# Plan: Refactor Menu Item to Centralized Widget

## Goal
Refactor `menu_screen.dart` to use a centralized widget for menu items (buttons), replacing the local `_MenuItem` implementation. This will improve code reusability and consistency across the application.

## User Review Required
> [!NOTE]
> I will be creating a new widget `StandardMenuItem` in `lib/core/widgets/standard_menu_item.dart`.
> I also noticed `HustlerDrawer` uses a similar `_DrawerItem`. I plan to refactor `HustlerDrawer` to use this new centralized widget as well to ensure consistency.

## Proposed Changes

### Core Widgets
#### [NEW] [standard_menu_item.dart](file:///c:/devs/flutter/kasi_hustle/lib/core/widgets/standard_menu_item.dart)
- Create `StandardMenuItem` stateless widget.
- It will encapsulate `ListTile` styling used in `menu_screen.dart` and `hustler_drawer.dart`.
- Properties:
  - `icon`: IconData
  - `label`: String
  - `subtitle`: String?
  - `onTap`: VoidCallback
  - `trailing`: Widget? (Default to chevron or null based on usage)
  - `textColor`: Color?
  - `iconColor`: Color?

### Menu Feature
#### [MODIFY] [menu_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/menu/presentation/screens/menu_screen.dart)
- Import `standard_menu_item.dart`.
- Replace `_MenuItem` usages with `StandardMenuItem`.
- Remove `_MenuItem` class.

### Home Feature (Drawer)
#### [MODIFY] [hustler_drawer.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/widgets/hustler_drawer.dart)
- Import `standard_menu_item.dart`.
- Replace `_DrawerItem` usages with `StandardMenuItem`.
- Remove `_DrawerItem` class.

## Verification Plan

### Automated Tests
- Non-applicable as this is a UI refactor.

### Manual Verification
1.  **Menu Screen**:
    - Navigate to the Menu Screen.
    - Verify all menu items (Personal Info, Payment, Support, etc.) look correct (icon, text, chevron).
    - detailed check on "Logout" button (red color).
    - Test tapping an item (e.g. Personal Info) and verify navigation works.

2.  **Drawer (HustlerDrawer)**:
    - Open the side drawer.
    - Verify menu items appear correctly.
    - Test tapping an item and verify interaction.
