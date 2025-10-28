import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_state.dart';
import 'package:kasi_hustle/features/profile/presentation/widgets/map_cache_settings.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(userProfileService: UserProfileService())
            ..add(LoadProfile()),
      child: const ProfileScreenContent(),
    );
  }
}

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: StyledLoadSpinner());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Ionicons.alert_circle_outline,
                    color: colorScheme.error,
                    size: IconSizes.xl,
                  ),
                  VSpace.lg,
                  UiText(
                    text: state.message,
                    style: TextStyles.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  VSpace.lg,
                  PrimaryBtn(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfile());
                    },
                    label: 'Retry',
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdating) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdating).profile;
            final isUpdating = state is ProfileUpdating;

            return Stack(
              children: [
                Container(
                  color: AppColors.darkSurface,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Insets.lg),
                        child: Column(
                          children: [
                            VSpace.xxl,
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.primaryContainer,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                  child: profile.profileImage != null
                                      ? ClipOval(
                                          child: Image.network(
                                            profile.profileImage!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Ionicons.person,
                                          size: 60,
                                          color: colorScheme.onPrimary,
                                        ),
                                ),
                                if (profile.isVerified)
                                  Positioned(
                                    bottom: 5,
                                    right: 5,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Ionicons.checkmark_done,
                                        color: colorScheme.onSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            VSpace.lg,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                UiText(
                                  text:
                                      '${profile.firstName} ${profile.lastName}',
                                  style: TextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.surface,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  HSpace.sm,
                                  Icon(
                                    Icons.verified,
                                    color: Color(0xFF00D26A),
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),
                            VSpace.xs,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Insets.med,
                                vertical: Insets.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: .2,
                                ),
                                borderRadius: Corners.fullBorder,
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Ionicons.construct_outline,
                                    color: colorScheme.primary,
                                    size: IconSizes.xs,
                                  ),
                                  HSpace.xs,
                                  UiText(
                                    text: profile.userType == 'hustler'
                                        ? 'Hustler'
                                        : 'Job Provider',
                                    style: TextStyles.labelMedium.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                          ),
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    VSpace.xl,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Insets.lg,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              context: context,
                                              icon: Ionicons.star,
                                              value: profile.rating
                                                  .toStringAsFixed(1),
                                              label: 'Rating',
                                            ),
                                          ),
                                          HSpace.med,
                                          Expanded(
                                            child: _buildStatCard(
                                              context: context,
                                              icon: Ionicons
                                                  .chatbox_ellipses_outline,
                                              value: '${profile.totalReviews}',
                                              label: 'Reviews',
                                            ),
                                          ),
                                          HSpace.med,
                                          Expanded(
                                            child: _buildStatCard(
                                              context: context,
                                              icon: Ionicons.briefcase,
                                              value: '${profile.completedJobs}',
                                              label: 'Jobs Done',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    VSpace.xl,

                                    _buildSectionTitle('About Me'),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Insets.lg,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(Insets.lg),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainer,
                                          borderRadius: Corners.medBorder,
                                          border: Border.all(
                                            color: colorScheme.outline
                                                .withValues(alpha: .1),
                                          ),
                                        ),
                                        child: UiText(
                                          text:
                                              profile.bio ?? 'No bio added yet',
                                          style: TextStyles.bodyLarge.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: .8),
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (profile.userType == 'hustler') ...[
                                      VSpace.xl,
                                      _buildSectionTitle('Primary Skills'),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Insets.lg,
                                        ),
                                        child: Wrap(
                                          spacing: Insets.sm,
                                          runSpacing: Insets.sm,
                                          children: profile.primarySkills.map((
                                            skill,
                                          ) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Insets.med,
                                                vertical: Insets.sm,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    Corners.fullBorder,
                                                border: Border.all(
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Ionicons.star,
                                                    color: colorScheme.primary,
                                                    size: IconSizes.xs,
                                                  ),
                                                  HSpace.xs,
                                                  UiText(
                                                    text: skill,
                                                    style: TextStyles.labelLarge
                                                        .copyWith(
                                                          color: colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      VSpace.xl,
                                      _buildSectionTitle('Additional Skills'),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: Insets.lg,
                                        ),
                                        child: Wrap(
                                          spacing: Insets.sm,
                                          runSpacing: Insets.sm,
                                          children: profile.secondarySkills.map(
                                            (skill) {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: Insets.med,
                                                  vertical: Insets.sm,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.secondary
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      Corners.fullBorder,
                                                  border: Border.all(
                                                    color:
                                                        colorScheme.secondary,
                                                  ),
                                                ),
                                                child: UiText(
                                                  text: skill,
                                                  style: TextStyles.labelMedium
                                                      .copyWith(
                                                        color: colorScheme
                                                            .secondary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    ],
                                    VSpace.xl,
                                    UiText(
                                      text:
                                          'Member since ${_formatDate(profile.createdAt)}',
                                      style: TextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: .5,
                                        ),
                                      ),
                                    ),
                                    VSpace.xl,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Insets.lg,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: PrimaryBtn(
                                          onPressed: () {
                                            _navigateToEditProfile(
                                              context,
                                              profile,
                                            );
                                          },
                                          label: 'Edit Profile',
                                          icon: Ionicons.create_outline,
                                        ),
                                      ),
                                    ),
                                    VSpace.med,

                                    // Map Cache Settings
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Insets.lg,
                                      ),
                                      child: const MapCacheSettings(),
                                    ),
                                    VSpace.med,

                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Insets.lg,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: SecondaryBtn(
                                          icon: Ionicons.log_out_outline,
                                          label: 'Logout',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: UiText(
                                                  text: 'Logout',
                                                  style: TextStyles.titleLarge,
                                                ),
                                                content: UiText(
                                                  text:
                                                      'Are you sure you want to logout?',
                                                  style: TextStyles.bodyLarge,
                                                ),
                                                actions: [
                                                  TextBtn(
                                                    'Cancel',
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                  ),
                                                  TextBtn(
                                                    'Logout',
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      context
                                                          .read<AppBloc>()
                                                          .add(
                                                            AppLogoutRequested(),
                                                          );
                                                    },
                                                    color: colorScheme.error,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    VSpace.xxl,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUpdating)
                  Container(
                    color: colorScheme.surface.withValues(alpha: .7),
                    child: const Center(child: StyledLoadSpinner()),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
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
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: IconSizes.med),
          VSpace.sm,
          UiText(
            text: value,
            style: TextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          VSpace.xs,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Insets.lg,
        vertical: Insets.med,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: UiText(text: title, style: TextStyles.titleLarge),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Add this to the top of profile_screen.dart to navigate to edit screen:

  // In _ProfileScreenContentState, replace _showEditProfileDialog with:
  void _navigateToEditProfile(BuildContext context, UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: EditProfileScreen(profile: profile),
        ),
      ),
    );
  }
}
