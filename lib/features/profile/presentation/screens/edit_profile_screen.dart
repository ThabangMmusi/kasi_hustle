import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/utils/ui_utils.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/skill_selection_widget.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      setState(() {
        final hasConnection =
            results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet) ||
            results.contains(ConnectivityResult.vpn) ||
            results.contains(ConnectivityResult.other);
        _isOffline = !hasConnection;
      });
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      final hasConnection =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet) ||
          results.contains(ConnectivityResult.vpn) ||
          results.contains(ConnectivityResult.other);
      _isOffline = !hasConnection;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  final List<String> _availableSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Tiling',
    'Roofing',
    'Welding',
    'Moving',
    'Handyman',
    'Security',
    'Catering',
    'Photography',
    'Hair & Beauty',
    'Tutoring',
  ];

  void _showPrimarySkillsBottomSheet(
    BuildContext context,
    UserProfile profile,
  ) {
    final tempPrimarySkills = List<String>.from(profile.primarySkills);

    final profileBloc = context.read<ProfileBloc>();

    UiUtils.showGlobalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BlocProvider.value(
        value: profileBloc,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            // Filter out skills already in secondary
            final availableSkills = _availableSkills
                .where((skill) => !profile.secondarySkills.contains(skill))
                .toList();

            void toggleSkill(String skill) {
              setModalState(() {
                if (tempPrimarySkills.contains(skill)) {
                  tempPrimarySkills.remove(skill);
                } else {
                  if (tempPrimarySkills.length < 5) {
                    tempPrimarySkills.add(skill);
                  }
                }
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: Insets.lg).copyWith(
                    bottom: bottomPadding + Insets.med,
                  ), // Add dynamic bottom padding
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: Insets.med),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(Insets.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UiText(
                              text: 'Primary Skills (Top 5)',
                              style: TextStyles.titleLarge,
                            ),
                            TextBtn(
                              'Clear',
                              onPressed: () {
                                setModalState(() {
                                  tempPrimarySkills.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VSpace.lg,
                              UiText(
                                text: 'Select up to 5 skills you are best at.',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              VSpace.med,
                              SkillSelectionWidget(
                                availableSkills: availableSkills,
                                selectedSkills: tempPrimarySkills,
                                onSkillSelected: toggleSkill,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom actions
                      Container(
                        padding: EdgeInsets.all(Insets.lg),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
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
                                onPressed: tempPrimarySkills.isEmpty
                                    ? null
                                    : () {
                                        final updatedProfile = profile.copyWith(
                                          primarySkills: tempPrimarySkills,
                                        );
                                        // Instant update
                                        context.read<ProfileBloc>().add(
                                          UpdateProfile(
                                            profile: updatedProfile,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                label: 'Apply',
                                icon: Ionicons.checkmark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showSecondarySkillsBottomSheet(
    BuildContext context,
    UserProfile profile,
  ) {
    final tempSecondarySkills = List<String>.from(profile.secondarySkills);

    final profileBloc = context.read<ProfileBloc>();

    UiUtils.showGlobalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BlocProvider.value(
        value: profileBloc,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            // Filter out skills already in primary
            final availableSkills = _availableSkills
                .where((skill) => !profile.primarySkills.contains(skill))
                .toList();

            void toggleSkill(String skill) {
              setModalState(() {
                if (tempSecondarySkills.contains(skill)) {
                  tempSecondarySkills.remove(skill);
                } else {
                  tempSecondarySkills.add(skill);
                }
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Insets.lg,
                  ).copyWith(bottom: bottomPadding + Insets.med),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: Insets.med),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(Insets.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UiText(
                              text: 'Additional Skills',
                              style: TextStyles.titleLarge,
                            ),
                            TextBtn(
                              'Clear',
                              onPressed: () {
                                setModalState(() {
                                  tempSecondarySkills.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VSpace.lg,
                              UiText(
                                text: 'Select other skills you offer.',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              VSpace.med,
                              SkillSelectionWidget(
                                availableSkills: availableSkills,
                                selectedSkills: tempSecondarySkills,
                                onSkillSelected: toggleSkill,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom actions
                      Container(
                        padding: EdgeInsets.all(Insets.lg),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
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
                                    secondarySkills: tempSecondarySkills,
                                  );
                                  context.read<ProfileBloc>().add(
                                    UpdateProfile(profile: updatedProfile),
                                  );
                                  Navigator.pop(context);
                                },
                                label: 'Apply',
                                icon: Ionicons.checkmark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    UiUtils.showGlobalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: Insets.lg,
          ).copyWith(bottom: bottomPadding + Insets.med),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              VSpace.lg,
              ListTile(
                leading: Icon(
                  Ionicons.log_out_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: UiText(text: 'Sign Out', style: TextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context); // Close sheet
                  _showLogoutDialog(context);
                },
              ),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
              ListTile(
                leading: Icon(
                  Ionicons.trash_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: UiText(
                  text: 'Delete Account',
                  style: TextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountSheet(context);
                },
              ),
              VSpace.med,
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: UiText(text: 'Logout', style: TextStyles.titleLarge),
        content: UiText(
          text: 'Are you sure you want to logout?',
          style: TextStyles.bodyLarge,
        ),
        actions: [
          TextBtn('Cancel', onPressed: () => Navigator.pop(context)),
          TextBtn(
            'Logout',
            onPressed: () {
              Navigator.pop(context);
              context.read<AppBloc>().add(AppLogoutRequested());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountSheet(BuildContext context) {
    UiUtils.showGlobalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            UiText(
              text: 'Delete Account',
              style: TextStyles.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            VSpace.med,
            UiText(
              text:
                  'This action is irreversible. All your data will be permanently removed.',
              style: TextStyles.bodyMedium,
            ),
            VSpace.lg,
            PrimaryBtn(
              label: 'Delete Permanently',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Delete Account functionality pending...'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
            ),
            VSpace.med,
            TextBtn('Cancel', onPressed: () => Navigator.pop(context)),
            VSpace.lg,
          ],
        ),
      ),
    );
  }

  Widget _buildInteractableSection({
    required BuildContext context,
    required String title,
    required Widget content,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Corners.medBorder,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(Insets.lg),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF7F2),
            borderRadius: Corners.medBorder,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // VSpace.sm,
                    content,
                  ],
                ),
              ),
              HSpace.med,
              Icon(
                Ionicons.chevron_forward,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                size: IconSizes.sm,
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isVerified = widget.profile.isVerified;

    return Scaffold(
      appBar: AppBar(
        title: UiText(text: 'Account Info', style: TextStyles.titleLarge),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFCF7F2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Ionicons.close,
                color: colorScheme.onSurface,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onPressed: () => _showMoreOptions(context),
          ),
          HSpace.sm,
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer,
                      image: widget.profile.profileImage != null
                          ? DecorationImage(
                              image: NetworkImage(widget.profile.profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.profile.profileImage == null
                        ? Icon(
                            Ionicons.person,
                            size: 40,
                            color: colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VSpace.xl,

            // Verification Section
            Container(
              padding: EdgeInsets.all(Insets.med),
              decoration: BoxDecoration(
                color: isVerified
                    ? colorScheme.secondary.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainer,
                borderRadius: Corners.medBorder,
                border: Border.all(
                  color: isVerified
                      ? colorScheme.secondary
                      : colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isVerified
                        ? Ionicons.checkmark_circle
                        : Ionicons.alert_circle_outline,
                    color: isVerified
                        ? colorScheme.secondary
                        : colorScheme.onSurface,
                  ),
                  HSpace.med,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UiText(
                          text: isVerified
                              ? 'Verified Account'
                              : 'Not Verified',
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isVerified
                                ? colorScheme.secondary
                                : colorScheme.onSurface,
                          ),
                        ),
                        if (!isVerified)
                          UiText(
                            text: 'Verify your account to build trust.',
                            style: TextStyles.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (!isVerified)
                    SmallPrimaryBtn(
                      label: 'Verify',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Verification flow coming soon'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            VSpace.xl,

            // Fields
            _buildInteractableSection(
              context: context,
              title: 'Names',
              content: Text(
                '${widget.profile.firstName} ${widget.profile.lastName}',
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              onTap: () =>
                  context.pushNamed('editNames', extra: widget.profile),
            ),
            VSpace.med,
            _buildInteractableSection(
              context: context,
              title: 'Contacts',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiText(
                    text: widget.profile.email ?? 'No email',
                    style: TextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  if (widget.profile.phoneNumber != null) ...[
                    VSpace.xs,
                    UiText(
                      text: widget.profile.phoneNumber!,
                      style: TextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () =>
                  context.pushNamed('editContacts', extra: widget.profile),
            ),

            if (widget.profile.userType == 'hustler') ...[
              VSpace.med,
              _buildInteractableSection(
                context: context,
                title: 'Primary Skills',
                onTap: () =>
                    _showPrimarySkillsBottomSheet(context, widget.profile),
                content: Text(
                  widget.profile.primarySkills.isEmpty
                      ? 'Add primary skills'
                      : widget.profile.primarySkills.join(', '),
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              VSpace.med,
              _buildInteractableSection(
                context: context,
                title: 'Additional Skills',
                onTap: () =>
                    _showSecondarySkillsBottomSheet(context, widget.profile),
                content: Text(
                  widget.profile.secondarySkills.isEmpty
                      ? 'Add secondary skills'
                      : widget.profile.secondarySkills.join(', '),
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ],
            VSpace.med,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Member since ${_formatDate(widget.profile.createdAt)}',
                  style: TextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: .5),
                  ),
                ),
              ],
            ),
            if (_isOffline)
              Padding(
                padding: EdgeInsets.only(top: Insets.lg),
                child: Container(
                  padding: EdgeInsets.all(Insets.med),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: Corners.smBorder,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: colorScheme.error),
                      HSpace.med,
                      Expanded(
                        child: Text(
                          'You are offline. Editing is disabled.',
                          style: TextStyles.bodyMedium.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            VSpace.xxl, // Extra padding at bottom
          ],
        ),
      ),
    );
  }
}

class SmallPrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const SmallPrimaryBtn({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: Insets.med, vertical: 0),
        minimumSize: const Size(0, 32),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Text(
        label,
        style: TextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
