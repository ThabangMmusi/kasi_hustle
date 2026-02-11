import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/features/search/presentation/controllers/search_focus_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/bloc/network/network_bloc.dart';
import 'package:kasi_hustle/core/widgets/offline_bottom_banner.dart';

// ==================== MAIN LAYOUT WITH BOTTOM NAV ====================

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final bool isHustler;

  const MainLayout({
    super.key,
    required this.navigationShell,
    this.isHustler = true,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    return widget.navigationShell.currentIndex;
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    if (index == 1) {
      SearchFocusController().requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: widget.navigationShell,
        bottomNavigationBar: BlocBuilder<NetworkBloc, NetworkState>(
          builder: (context, state) {
            final isOffline = state is NetworkFailure;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: Shadows.universal,
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: !isOffline,
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
                                  icon: Ionicons.menu_outline,
                                  selectedIcon: Ionicons.menu,
                                  label: 'Menu',
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
                                  icon: Ionicons.menu_outline,
                                  selectedIcon: Ionicons.menu,
                                  label: 'Menu',
                                  index: 3,
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
                if (isOffline) const OfflineBottomBanner(),
              ],
            );
          },
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
