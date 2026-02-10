import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';

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
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: colorScheme.surface,
                      surfaceTintColor: colorScheme.surface,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(
                          Ionicons.chevron_back,
                          color: colorScheme.onSurface,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            Ionicons.create_outline,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () =>
                              _navigateToEditProfile(context, profile),
                        ),
                        HSpace.sm,
                      ],
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          final double expandedHeight = 250.0;
                          final double paddingMap = MediaQuery.of(
                            context,
                          ).padding.top;
                          final double minHeight = paddingMap + kToolbarHeight;
                          final double t =
                              ((constraints.maxHeight - minHeight) /
                                      (expandedHeight - minHeight))
                                  .clamp(0.0, 1.0);

                          final double screenWidth = MediaQuery.of(
                            context,
                          ).size.width;

                          // 1. Avatar Size & Position
                          final double avatarSize = 44 + (56 * t); // 44 -> 100
                          final double avatarExpandedLeft =
                              (screenWidth - avatarSize) / 2;
                          final double avatarCollapsedLeft =
                              16 + 32; // Standard back button space (approx 48)
                          final double avatarLeft =
                              (avatarCollapsedLeft * (1 - t)) +
                              (avatarExpandedLeft * t);

                          final double avatarExpandedTop =
                              40 + paddingMap; // Margin from top in expanded
                          final double avatarCollapsedTop =
                              paddingMap + ((kToolbarHeight - 44) / 2);
                          final double avatarTop =
                              (avatarCollapsedTop * (1 - t)) +
                              (avatarExpandedTop * t);

                          // 2. Text (Name & Type) Calculations
                          final double textExpandedTop =
                              avatarExpandedTop + avatarSize + 16;
                          final double textCollapsedTop =
                              paddingMap + ((kToolbarHeight - 20) / 2);
                          final double textTop =
                              (textCollapsedTop * (1 - t)) +
                              (textExpandedTop * t);

                          final double textCollapsedLeft =
                              avatarCollapsedLeft +
                              44 +
                              10; // Avt(44) + Gap(10)
                          final double textLeft =
                              (textCollapsedLeft *
                              (1 - t)); // Centered in expanded via Align

                          final double textWidth =
                              (screenWidth - (textCollapsedLeft * (1 - t)) - 16)
                                  .clamp(0.0, screenWidth);

                          // 3. Asset Scaling/Opacity
                          final double badgeOpacity = (t * 2).clamp(
                            0.0,
                            1.0,
                          ); // Fades out in the first half of collapsing
                          final double verifiedScale = (t * 2 - 1).clamp(
                            0.0,
                            1.0,
                          ); // Only shows in second half of expanding

                          return Container(
                            color: colorScheme.surface,
                            child: Stack(
                              children: [
                                // --- Content Layer ---
                                // Name & Type
                                Positioned(
                                  top: textTop,
                                  left: textLeft,
                                  width: textWidth,
                                  child: Align(
                                    alignment: Alignment.lerp(
                                      Alignment.centerLeft,
                                      Alignment.center,
                                      t,
                                    )!,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${profile.firstName} ${profile.lastName}',
                                          style: TextStyle.lerp(
                                            TextStyles.titleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            TextStyles.headlineSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            t,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        // Type Badge
                                        Opacity(
                                          opacity: badgeOpacity,
                                          child: Transform.scale(
                                            scale: 0.8 + (0.2 * t),
                                            alignment: Alignment.center,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: 4 * t,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    Corners.fullBorder,
                                              ),
                                              child: Text(
                                                profile.userType == 'hustler'
                                                    ? 'Hustler'
                                                    : 'Job Provider',
                                                style: TextStyles.labelSmall
                                                    .copyWith(
                                                      color:
                                                          colorScheme.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Avatar
                                Positioned(
                                  top: avatarTop,
                                  left: avatarLeft,
                                  width: avatarSize,
                                  height: avatarSize,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colorScheme.primary,
                                              colorScheme.primaryContainer,
                                            ],
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width:
                                                1 +
                                                (1.5 *
                                                    t), // Border thickens as it expands
                                          ),
                                          boxShadow: t > 0.5
                                              ? Shadows.universal
                                              : null,
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
                                                size: avatarSize * 0.5,
                                                color: colorScheme.onPrimary,
                                              ),
                                      ),
                                      // Verified Icon
                                      if (profile.isVerified)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Transform.scale(
                                            scale: verifiedScale,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: colorScheme.secondary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: colorScheme.surface,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Ionicons.checkmark_done,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          VSpace.med,
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
                                    value: profile.rating.toStringAsFixed(1),
                                    label: 'Rating',
                                  ),
                                ),
                                HSpace.med,
                                Expanded(
                                  child: _buildStatCard(
                                    context: context,
                                    icon: Ionicons.chatbox_ellipses_outline,
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

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Insets.lg,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _showEditBioBottomSheet(context, profile),
                                borderRadius: Corners.medBorder,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(Insets.lg),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainer,
                                    borderRadius: Corners.medBorder,
                                    border: Border.all(
                                      color: colorScheme.outline.withValues(
                                        alpha: .1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (profile.bio != null) ...[
                                        UiText(
                                          text: 'About Me',
                                          style: TextStyles.labelSmall.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        VSpace.xs,
                                      ],
                                      UiText(
                                        text: profile.bio ?? 'About me',
                                        style: TextStyles.bodyLarge.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(
                                                alpha: profile.bio != null
                                                    ? .8
                                                    : .5,
                                              ),
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (profile.userType == 'hustler') ...[
                            VSpace.xl,
                            _buildStandardSection(
                              context: context,
                              icon: Icons.star,
                              title: 'Primary Skills',
                              content: Wrap(
                                spacing: Insets.sm,
                                runSpacing: Insets.sm,
                                children: profile.primarySkills.map((skill) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.sm,
                                      vertical: Insets.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: Corners.fullBorder,
                                      border: Border.all(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    child: UiText(
                                      text: skill,
                                      style: TextStyles.labelMedium.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            VSpace.xl,
                            _buildStandardSection(
                              context: context,
                              icon: Ionicons.add_circle_outline,
                              title: 'Additional Skills',
                              content: Wrap(
                                spacing: Insets.sm,
                                runSpacing: Insets.sm,
                                children: profile.secondarySkills.map((skill) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Insets.sm,
                                      vertical: Insets.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: Corners.fullBorder,
                                      border: Border.all(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    child: UiText(
                                      text: skill,
                                      style: TextStyles.labelMedium.copyWith(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
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
                                            context.read<AppBloc>().add(
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

  Widget _buildStandardSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Insets.lg),
      child: Container(
        padding: EdgeInsets.all(Insets.lg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: Corners.medBorder,
          border: Border.all(color: colorScheme.outline.withValues(alpha: .1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: IconSizes.med),
                HSpace.sm,
                UiText(
                  text: title,
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            VSpace.med,
            content,
          ],
        ),
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

  void _showEditBioBottomSheet(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = TextEditingController(text: profile.bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.all(Insets.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VSpace.sm,
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              VSpace.lg,
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: null,
                minLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell others about yourself and your experience...',
                ),
                style: TextStyles.bodyLarge,
              ),
              VSpace.lg,
              Row(
                children: [
                  Expanded(
                    child: TextBtn(
                      'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  HSpace.med,
                  Expanded(
                    flex: 2,
                    child: PrimaryBtn(
                      onPressed: () {
                        final updatedProfile = profile.copyWith(
                          bio: controller.text.trim().isEmpty
                              ? null
                              : controller.text.trim(),
                        );
                        context.read<ProfileBloc>().add(
                          UpdateProfile(profile: updatedProfile),
                        );
                        Navigator.pop(context);
                      },
                      label: 'Save',
                      icon: Ionicons.checkmark,
                    ),
                  ),
                ],
              ),
              VSpace.med,
            ],
          ),
        ),
      ),
    );
  }
}
