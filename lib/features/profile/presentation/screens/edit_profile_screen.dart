import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/core/widgets/skill_selection_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late List<String> _primarySkills;
  late List<String> _secondarySkills;

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

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _primarySkills = List<String>.from(widget.profile.primarySkills);
    _secondarySkills = List<String>.from(widget.profile.secondarySkills);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showPrimarySkillsBottomSheet() {
    final tempPrimarySkills = List<String>.from(_primarySkills);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          // Filter out skills already in secondary
          final availableSkills = _availableSkills
              .where((skill) => !_secondarySkills.contains(skill))
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
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar - wrapped in GestureDetector to allow dragging
                  GestureDetector(
                    onVerticalDragUpdate: (_) {},
                    child: Container(
                      margin: EdgeInsets.only(top: Insets.med),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header - also draggable
                  GestureDetector(
                    onVerticalDragUpdate: (_) {},
                    child: Padding(
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
                    child: SafeArea(
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
                                      setState(() {
                                        _primarySkills = tempPrimarySkills;
                                      });
                                      Navigator.pop(context);
                                    },
                              label: 'Apply',
                              icon: Ionicons.checkmark,
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
        },
      ),
    );
  }

  void _showSecondarySkillsBottomSheet() {
    final tempSecondarySkills = List<String>.from(_secondarySkills);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          // Filter out skills already in primary
          final availableSkills = _availableSkills
              .where((skill) => !_primarySkills.contains(skill))
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
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar - wrapped in GestureDetector to allow dragging
                  GestureDetector(
                    onVerticalDragUpdate: (_) {},
                    child: Container(
                      margin: EdgeInsets.only(top: Insets.med),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header - also draggable
                  GestureDetector(
                    onVerticalDragUpdate: (_) {},
                    child: Padding(
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
                    child: SafeArea(
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
                                setState(() {
                                  _secondarySkills = tempSecondarySkills;
                                });
                                Navigator.pop(context);
                              },
                              label: 'Apply',
                              icon: Ionicons.checkmark,
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
        },
      ),
    );
  }

  void _saveProfile() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: UiText(text: 'First and last name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_primarySkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: UiText(text: 'Please select at least one primary skill'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create updated profile using copyWith
    final updatedProfile = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      primarySkills: _primarySkills,
      secondarySkills: _secondarySkills,
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
    );

    context.read<ProfileBloc>().add(UpdateProfile(profile: updatedProfile));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: UiText(text: 'Edit Profile', style: TextStyles.titleLarge),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: UiText(
              text: 'Save',
              style: TextStyles.labelLarge.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
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
                      border: Border.all(color: colorScheme.primary, width: 3),
                    ),
                    child: widget.profile.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              widget.profile.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Ionicons.person,
                            size: 60,
                            color: colorScheme.onPrimary,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const UiText(
                              text: 'Upload image functionality',
                            ),
                            backgroundColor: colorScheme.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(Insets.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Ionicons.camera_outline,
                          color: colorScheme.onPrimary,
                          size: IconSizes.sm,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            VSpace.xxl,

            // Name Fields
            StyledTextInput(
              controller: _firstNameController,
              label: 'First Name',
            ),
            VSpace.lg,

            StyledTextInput(
              controller: _lastNameController,
              label: 'Last name',
            ),

            VSpace.xl,

            // Primary Skills Section - Only show for hustlers
            if (widget.profile.userType == 'hustler') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UiText(
                    text: 'Primary Skills',
                    style: TextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SecondaryBtn(
                    label: 'Edit',
                    onPressed: _showPrimarySkillsBottomSheet,
                    icon: Ionicons.create_outline,
                  ),
                ],
              ),
              VSpace.sm,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Insets.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: Corners.medBorder,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: _primarySkills.isEmpty
                    ? Row(
                        children: [
                          Icon(
                            Ionicons.alert_circle_outline,
                            color: colorScheme.error,
                            size: IconSizes.sm,
                          ),
                          HSpace.sm,
                          Expanded(
                            child: UiText(
                              text:
                                  'No primary skills selected. Tap "Edit" to add.',
                              style: TextStyles.bodyMedium.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Wrap(
                        spacing: Insets.sm,
                        runSpacing: Insets.sm,
                        children: _primarySkills.map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Insets.med,
                              vertical: Insets.sm,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: Corners.fullBorder,
                              border: Border.all(color: colorScheme.primary),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Ionicons.checkmark_circle,
                                  color: colorScheme.primary,
                                  size: IconSizes.xs,
                                ),
                                HSpace.xs,
                                UiText(
                                  text: skill,
                                  style: TextStyles.labelMedium.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              VSpace.xl,
              // Secondary Skills Section - Only show for hustlers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UiText(
                    text: 'Additional Skills',
                    style: TextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SecondaryBtn(
                    label: 'Edit',
                    onPressed: _showSecondarySkillsBottomSheet,
                    icon: Ionicons.create_outline,
                  ),
                ],
              ),
              VSpace.sm,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Insets.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: Corners.medBorder,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: _secondarySkills.isEmpty
                    ? Row(
                        children: [
                          Icon(
                            Ionicons.information_circle_outline,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            size: IconSizes.sm,
                          ),
                          HSpace.sm,
                          Expanded(
                            child: UiText(
                              text: 'No additional skills. Tap "Edit" to add.',
                              style: TextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Wrap(
                        spacing: Insets.sm,
                        runSpacing: Insets.sm,
                        children: _secondarySkills.map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Insets.med,
                              vertical: Insets.sm,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: Corners.fullBorder,
                              border: Border.all(color: colorScheme.secondary),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UiText(
                                  text: skill,
                                  style: TextStyles.labelMedium.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              VSpace.xl,
            ],

            // Bio Field
            UiText(
              text: 'Bio',
              style: TextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            VSpace.sm,
            StyledTextInput(
              controller: _bioController,
              label: 'Tell others about yourself and your experience...',
              numLines: 5,
            ),
            VSpace.xs,
            UiText(
              text:
                  'A good bio helps clients trust you and choose you for their jobs.',
              style: TextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            VSpace.xxl,

            // Save Button
            SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onPressed: _saveProfile,
                label: 'Save Changes',
                icon: Ionicons.checkmark_circle_outline,
              ),
            ),

            VSpace.xl,
          ],
        ),
      ),
    );
  }
}
