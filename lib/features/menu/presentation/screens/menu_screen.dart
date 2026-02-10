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
            children: [
              // User Header with top padding for status bar
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Insets.lg,
                  Insets.xxl + MediaQuery.of(context).padding.top,
                  Insets.lg,
                  Insets.lg,
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
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
                    HSpace.lg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiText(
                            text: '${user.firstName} ${user.lastName}',
                            style: TextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          VSpace.xs,
                          Row(
                            children: [
                              const Icon(
                                Ionicons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              HSpace.xs,
                              UiText(
                                text:
                                    '${user.rating.toStringAsFixed(1)} Rating',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: Insets.med),
                  children: [
                    StandardMenuItem(
                      icon: Ionicons.person_outline,
                      label: 'Personal Information',
                      showChevron: true,
                      onTap: () {
                        debugPrint('Navigating to Profile (Personal Info)...');
                        context.pushNamed('profile');
                      },
                    ),
                    StandardMenuItem(
                      icon: Ionicons.card_outline,
                      label: 'Payment Method',
                      subtitle: 'Add bank details',
                      showChevron: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment Methods coming soon!'),
                          ),
                        );
                      },
                    ),
                    StandardMenuItem(
                      icon: Ionicons.help_circle_outline,
                      label: 'Support & Help',
                      showChevron: true,
                      onTap: () {},
                    ),
                    StandardMenuItem(
                      icon: Ionicons.settings_outline,
                      label: 'Settings',
                      showChevron: true,
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    StandardMenuItem(
                      icon: Ionicons.information_circle_outline,
                      label: 'About Kasi Hustle',
                      showChevron: true,
                      onTap: () {},
                    ),
                    // Logout
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
                  ],
                ),
              ),
              VSpace.xl,

              // Switch Role
              Padding(
                padding: EdgeInsets.all(Insets.lg),
                child: Container(
                  padding: EdgeInsets.all(Insets.med),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: Corners.medBorder,
                          ),
                        ),
                        child: UiText(
                          text: 'Switch to Hirer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
