import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';

// ==================== MAIN LAYOUT WITH BOTTOM NAV ====================

class MainLayout extends StatefulWidget {
  final Widget child;
  final bool isHustler;

  const MainLayout({super.key, required this.child, this.isHustler = true});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (widget.isHustler) {
      if (location == AppRoutes.home) return 0;
      if (location == AppRoutes.search) return 1;
      if (location == AppRoutes.applications) return 2;
      if (location == AppRoutes.profile) return 3;
    } else {
      if (location == AppRoutes.businessHome) return 0;
      if (location == AppRoutes.postJob) return 1;
      if (location == AppRoutes.applications) return 2;
      if (location == AppRoutes.profile) return 3;
    }

    return 0;
  }

  void _onItemTapped(int index) {
    if (widget.isHustler) {
      switch (index) {
        case 0:
          context.go(AppRoutes.home);
          break;
        case 1:
          context.go(AppRoutes.search);
          break;
        case 2:
          context.go(AppRoutes.applications);
          break;
        case 3:
          context.go(AppRoutes.profile);
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go(AppRoutes.businessHome);
          break;
        case 1:
          context.go(AppRoutes.postJob);
          break;
        case 2:
          context.go(AppRoutes.applications);
          break;
        case 3:
          context.go(AppRoutes.profile);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: Shadows.universal,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Insets.sm,
              vertical: Insets.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.isHustler
                  ? [
                      _buildNavItem(
                        icon: Ionicons.home_outline,
                        selectedIcon: Ionicons.home,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Ionicons.search_outline,
                        selectedIcon: Ionicons.search,
                        label: 'Search',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Ionicons.briefcase_outline,
                        selectedIcon: Ionicons.briefcase,
                        label: 'Applications',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Ionicons.person_outline,
                        selectedIcon: Ionicons.person,
                        label: 'Profile',
                        index: 3,
                      ),
                    ]
                  : [
                      _buildNavItem(
                        icon: Ionicons.home_outline,
                        selectedIcon: Ionicons.home,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Ionicons.add_circle_outline,
                        selectedIcon: Ionicons.add_circle,
                        label: 'Post Job',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Ionicons.briefcase_outline,
                        selectedIcon: Ionicons.briefcase,
                        label: 'Applicants',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Ionicons.person_outline,
                        selectedIcon: Ionicons.person,
                        label: 'Profile',
                        index: 3,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _calculateSelectedIndex(context) == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          borderRadius: Corners.medBorder,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Insets.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: IconSizes.med,
                ),
                VSpace.xs,
                Text(
                  label,
                  style: TextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
