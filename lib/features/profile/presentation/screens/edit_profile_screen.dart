import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/utils/ui_utils.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _phoneController = TextEditingController(
      text: widget.profile.phoneNumber ?? '',
    );

    _firstNameFocus.addListener(
      () => _onFocusChange(_firstNameFocus, 'firstName'),
    );
    _lastNameFocus.addListener(
      () => _onFocusChange(_lastNameFocus, 'lastName'),
    );
    _emailFocus.addListener(() => _onFocusChange(_emailFocus, 'email'));
    _phoneFocus.addListener(() => _onFocusChange(_phoneFocus, 'phone'));

    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      setState(() {
        // Fix: Check if results contains 'none' properly.
        // Wait, connectivity_plus 6.0+ returns List<ConnectivityResult>.
        // 'none' implies NO connection.
        _isOffline =
            results.contains(ConnectivityResult.none) && results.length == 1;
        // If list has mobile or wifi, it's online. If list has ONLY none, it's offline.
        // Actually, check if ANY valid connection exists.
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onFocusChange(FocusNode node, String field) {
    if (!node.hasFocus) {
      _saveProfile();
    }
  }

  void _saveProfile() {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot save changes while offline.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final updatedProfile = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    // Only update if changes were made
    if (updatedProfile.firstName != widget.profile.firstName ||
        updatedProfile.lastName != widget.profile.lastName ||
        updatedProfile.email != widget.profile.email ||
        updatedProfile.phoneNumber != widget.profile.phoneNumber) {
      context.read<ProfileBloc>().add(UpdateProfile(profile: updatedProfile));
    }
  }

  void _showMoreOptions(BuildContext context) {
    UiUtils.showGlobalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: Insets.lg).copyWith(
            bottom: bottomPadding + Insets.med,
          ), // Add dynamic bottom padding
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isVerified = widget.profile.isVerified;

    return Scaffold(
      appBar: AppBar(
        title: UiText(text: 'Edit Profile', style: TextStyles.titleLarge),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Ionicons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
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
                    width: 100,
                    height: 100,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Ionicons.camera,
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
            StyledTextInput(
              controller: _firstNameController,
              label: 'First Name',
              hintText: 'Enter your first name',
              focusNode: _firstNameFocus,
              enabled: !_isOffline,
            ),
            VSpace.med,
            StyledTextInput(
              controller: _lastNameController,
              label: 'Last Name',
              hintText: 'Enter your last name',
              focusNode: _lastNameFocus,
              enabled: !_isOffline,
            ),
            VSpace.xl,

            StyledTextInput(
              controller: _emailController,
              label: 'Email Address',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocus,
              enabled: !_isOffline,
            ),
            VSpace.med,
            StyledTextInput(
              controller: _phoneController,
              label: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              focusNode: _phoneFocus,
              enabled: !_isOffline,
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
                        child: UiText(
                          text: 'You are offline. Editing is disabled.',
                          style: TextStyles.bodyMedium.copyWith(
                            color: colorScheme.error,
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
