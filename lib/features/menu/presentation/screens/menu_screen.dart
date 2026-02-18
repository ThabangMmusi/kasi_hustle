import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/standard_menu_item.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.status != AppStatus.authenticated || state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Header with top padding for status bar
              // VSpasce.med,
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: Insets.lg),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: _buildStatCard(
              //           context: context,
              //           icon: Ionicons.star,
              //           value: user.rating.toStringAsFixed(1),
              //           label: 'Rating',
              //         ),
              //       ),
              //       HSpace.med,
              //       Expanded(
              //         child: _buildStatCard(
              //           context: context,
              //           icon: Ionicons.chatbox_ellipses_outline,
              //           value: '${user.totalReviews}',
              //           label: 'Reviews',
              //         ),
              //       ),
              //       // HSpace.med,
              //       // Expanded(
              //       //   child: _buildStatCard(
              //       //     context: context,
              //       //     icon: Ionicons.briefcase,
              //       //     value: '${user.completedJobs}',
              //       //     label: 'Jobs Done',
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // VSpace.xl,

              // const Divider(),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: Insets.med),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        Insets.lg,
                        Insets.xxl + MediaQuery.of(context).padding.top,
                        Insets.lg,
                        Insets.lg,
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 80,
                            height: 80,
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
                                      size: 35,
                                      color: colorScheme.primary,
                                    ),
                            ),
                          ),
                          VSpace.med,
                          Column(
                            children: [
                              UiText(
                                text: '${user.firstName} ${user.lastName}',
                                style: TextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              VSpace.xs,
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Insets.sm,
                                  vertical: Insets.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: Corners.lgBorder,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Ionicons.hammer,
                                      size: 12,
                                      color: colorScheme.primary,
                                    ),

                                    HSpace.xs,
                                    UiText(
                                      text: user.userType
                                          .toLowerCase()
                                          .capitalizeFirst(),
                                      style: TextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF7F2),
                        borderRadius: Corners.medBorder,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StandardMenuItem(
                            icon: Ionicons.person_outline,
                            label: 'Manage Account',
                            showChevron: true,
                            onTap: () {
                              debugPrint(
                                'Navigating to Profile (Personal Info)...',
                              );
                              context.pushNamed('profile');
                            },
                          ),
                          StandardMenuItem(
                            icon: Ionicons.card_outline,
                            label: 'Wallet',
                            // subtitle: 'Add bank details',
                            showChevron: true,
                            onTap: () {
                              context.pushNamed('wallet');
                            },
                          ),
                          StandardMenuItem(
                            icon: Ionicons.settings_outline,
                            label: 'Settings',
                            showChevron: true,
                            onTap: () => context.push(AppRoutes.settings),
                          ),
                        ],
                      ),
                    ),
                    VSpace.lg,
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF7F2),
                        borderRadius: Corners.medBorder,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StandardMenuItem(
                            icon: Ionicons.help_circle_outline,
                            label: 'Support & Help',
                            showChevron: true,
                            onTap: () {},
                          ),

                          StandardMenuItem(
                            icon: Ionicons.information_circle_outline,
                            label: 'About Kasi Hustle',
                            showChevron: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    VSpace.lg,
                    // Logout
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Insets.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCF7F2),
                        borderRadius: Corners.medBorder,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StandardMenuItem(
                            icon: Ionicons.log_out_outline,
                            label: 'Logout',
                            textColor: Colors.red,
                            iconColor: Colors.red,
                            showChevron: true,
                            onTap: () {
                              context.read<AppBloc>().add(AppLogoutRequested());
                            },
                          ),
                          // Switch Role
                          Padding(
                            padding: EdgeInsets.all(Insets.lg),
                            child: Container(
                              padding: EdgeInsets.all(Insets.med),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: Corners.medBorder,
                              ),
                              child: Column(
                                children: [
                                  UiText(
                                    text: 'Looking to hire someone?',
                                    style: TextStyles.bodyMedium,
                                  ),
                                  VSpace.med,
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: Corners.medBorder,
                                      ),
                                    ),
                                    child: UiText(
                                      text: 'Switch to Hirer',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(Insets.med),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Corners.medBorder,
        border: Border.all(color: colorScheme.outline.withValues(alpha: .1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: IconSizes.sm),
          HSpace.sm,
          UiText(
            text: value,
            style: TextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          HSpace.xs,
          UiText(
            text: label,
            style: TextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  String? capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
