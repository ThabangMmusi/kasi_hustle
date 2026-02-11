import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/standard_menu_item.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/applications/presentation/screens/applications_screen.dart';
import 'package:kasi_hustle/features/home/bloc/home_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/profile_screen.dart';

class HustlerDrawer extends StatelessWidget {
  const HustlerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is! HomeLoaded) {
            // Show loading placeholder or guest view
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.fromLTRB(
                  Insets.lg,
                  Insets.xxl + MediaQuery.of(context).padding.top,
                  Insets.lg,
                  Insets.lg,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: user.profileImage != null
                                ? Image.network(
                                    user.profileImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Ionicons.person,
                                    size: 30,
                                    color: colorScheme.primary,
                                  ),
                          ),
                        ),
                        HSpace.med,
                        // Name & My Account
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UiText(
                                text: user.firstName,
                                style: TextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              VSpace.xs,
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context); // Close drawer
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      UiText(
                                        text: 'My Account',
                                        style: TextStyles.labelSmall.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      HSpace.xs,
                                      Icon(
                                        Ionicons.chevron_forward,
                                        size: 12,
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    VSpace.lg,
                    // Stats Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Insets.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            context,
                            label: 'Rating',
                            value: user.rating.toStringAsFixed(1),
                            icon: Ionicons.star,
                            color: Colors.amber,
                          ),
                          _buildStatItem(
                            context,
                            label: 'Reviews',
                            value: '${user.totalReviews}',
                            icon: Ionicons.chatbox_ellipses,
                            color: colorScheme.primary,
                          ),
                          _buildStatItem(
                            context,
                            label: 'Jobs',
                            value: '${user.completedJobs}',
                            icon: Ionicons.briefcase,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: Insets.med),
                  child: Column(
                    children: [
                      StandardMenuItem(
                        icon: Ionicons.card_outline,
                        label: 'Payment Method',
                        subtitle: 'Add bank details',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Methods coming soon!'),
                            ),
                          );
                        },
                      ),
                      StandardMenuItem(
                        icon: Ionicons.briefcase_outline,
                        label: 'My Applications',
                        subtitle: 'Passed, Upcoming, Declined',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplicationsScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 32,
                        indent: Insets.lg,
                        endIndent: Insets.lg,
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      StandardMenuItem(
                        icon: Ionicons.person_circle_outline,
                        label: 'Work Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      StandardMenuItem(
                        icon: Ionicons.help_circle_outline,
                        label: 'Support',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      StandardMenuItem(
                        icon: Ionicons.information_circle_outline,
                        label: 'About App',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Footer: Switch Role
              Container(
                margin: EdgeInsets.all(Insets.lg),
                padding: EdgeInsets.all(Insets.med),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: Corners.medBorder,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    UiText(
                      text: 'Need help with something?',
                      style: TextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    VSpace.med,
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement Role Switch Logic
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: Insets.med),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: Corners.medBorder,
                          boxShadow: Shadows.small,
                        ),
                        child: Center(
                          child: UiText(
                            text: 'Switch to Hirer',
                            style: TextStyles.labelLarge.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              VSpace.lg,
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        VSpace.xs,
        UiText(
          text: value,
          style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        UiText(
          text: label,
          style: TextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
