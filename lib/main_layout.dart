import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

import 'package:kasi_hustle/features/applications/presentation/screens/applications_screen.dart';

import 'package:kasi_hustle/features/home/presentation/screens/home_screen.dart';
import 'package:kasi_hustle/features/post_job/presentation/screens/post_job_screen.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/profile_screen.dart';
import 'package:kasi_hustle/features/search/presentation/screens/search_screen.dart';
import 'package:kasi_hustle/features/business_home/presentation/screens/business_home_screen.dart';

// ==================== MAIN LAYOUT WITH BOTTOM NAV ====================

class MainLayout extends StatefulWidget {
  const MainLayout({super.key, this.isHustler = true});
  final bool isHustler;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = widget.isHustler
        ? [
            HomeScreen(onSearchTap: () => changeTab(1)),
            const SearchScreen(),
            const ApplicationsScreen(),
            const ProfileScreen(),
          ]
        : [
            const BusinessHomeScreen(),
            const CreateJobScreen(),
            const ApplicationsScreen(),
            const ProfileScreen(),
          ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(index: _currentIndex, children: _screens),
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
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
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
