# Hustler Home Side Menu Redesign Plan

## Goal Description
Implement a specialized Side Menu (Drawer) for the Hustler Home screen. This drawer will serve as the central hub for the Hustler's profile summary, account navigation, application status, payment methods, and role switching (Hustler <-> Job Provider).

## User Review Required
> [!IMPORTANT]
> The "My Applications" section is described as leading straight to a page with tabs (Passed, Upcoming, Declined). I will ensure the button navigates to this page.

> [!NOTE]
> The "Switch Role" button is described as "removable". I will assume this means it's a dismissible or prominently placed card that might be hidden later, but for now, I'll make it a distinct section.

## Proposed Changes

### New Components

#### [NEW] [hustler_drawer.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/widgets/hustler_drawer.dart)
A new widget `HustlerDrawer` that implements the sidebar design.

**Structure:**
1.  **Header Section:**
    *   Row layout:
        *   Left: Avatar (CircleAvatar)
        *   Right:
            *   First Name
            *   "My Account" Button (Small outgoing link style)
    *   Bottom: Rating Row (Star Icon + Rating Value + "Rating" label).
2.  **Payment Section:**
    *   "Payment Methods" / "Banking Details" tile.
3.  **My Work / Applications Section:**
    *   "My Applications" tile (Navigates to key application statuses: Passed, Upcoming, Declined).
4.  **Work Profile Section:**
    *   "Work Profile" tile.
5.  **Support & About:**
    *   "Support" tile.
    *   "About App" tile.
6.  **Role Switch (Footer/Container):**
    *   Distinct container: "Become a Hirer" / "Switch to Job Provider".
    *   "Need help with something?" CTA.

### Modified Files

#### [MODIFY] [home_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/screens/home_screen.dart)
*   Add the `drawer` parameter to the `Scaffold` in `HomeScreenContent`.
*   Pass the `HustlerDrawer` widget.

## Verification Plan

### Manual Verification
1.  **Open Drawer:** Tap the menu button on the Home Screen.
2.  **Check Header:** Verify Avatar, Name, and Rating are displayed correctly using mock or real user data.
3.  **Navigation:**
    *   Tap "My Account" -> Should go to Profile.
    *   Tap "My Applications" -> Should go to Applications page (if exists) or show placeholder.
    *   Tap "Payment Methods" -> Placeholder/Navigation.
4.  **Role Switch:** Verify the visual presence of the switch button.
