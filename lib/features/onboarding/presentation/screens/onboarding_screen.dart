import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/progress_bar.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/features/verification/presentation/screens/verification_screen.dart';
import 'package:kasi_hustle/main_layout.dart';

// ==================== MODELS ====================

class OnboardingData {
  final String username;
  final String userType;
  final List<String> skills;
  final bool isVerified;

  OnboardingData({
    required this.username,
    required this.userType,
    required this.skills,
    required this.isVerified,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'user_type': userType,
      'skills': skills,
      'is_verified': isVerified,
    };
  }
}

// ==================== BLOC EVENTS ====================

abstract class OnboardingEvent {}

class NextStep extends OnboardingEvent {}

class PreviousStep extends OnboardingEvent {}

class SelectUserType extends OnboardingEvent {
  final String userType;
  SelectUserType(this.userType);
}

class UpdateUsername extends OnboardingEvent {
  final String username;
  UpdateUsername(this.username);
}

class ToggleSkill extends OnboardingEvent {
  final String skill;
  ToggleSkill(this.skill);
}

class CompleteOnboarding extends OnboardingEvent {
  final bool verifyNow;
  CompleteOnboarding(this.verifyNow);
}

// ==================== BLOC STATES ====================

abstract class OnboardingState {
  final int currentStep;
  final String? userType;
  final String? username;
  final List<String> selectedSkills;

  OnboardingState({
    required this.currentStep,
    this.userType,
    this.username,
    this.selectedSkills = const [],
  });
}

class OnboardingInProgress extends OnboardingState {
  OnboardingInProgress({
    required super.currentStep,
    super.userType,
    super.username,
    super.selectedSkills,
  });

  OnboardingInProgress copyWith({
    int? currentStep,
    String? userType,
    String? username,
    List<String>? selectedSkills,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      userType: userType ?? this.userType,
      username: username ?? this.username,
      selectedSkills: selectedSkills ?? this.selectedSkills,
    );
  }
}

class OnboardingSubmitting extends OnboardingState {
  OnboardingSubmitting({
    required super.currentStep,
    super.userType,
    super.username,
    super.selectedSkills,
  });
}

class OnboardingComplete extends OnboardingState {
  final bool needsVerification;

  OnboardingComplete({
    required super.currentStep,
    required this.needsVerification,
    super.userType,
    super.username,
    super.selectedSkills,
  });
}

class OnboardingError extends OnboardingState {
  final String message;

  OnboardingError({
    required super.currentStep,
    required this.message,
    super.userType,
    super.username,
    super.selectedSkills,
  });
}

// ==================== BLOC ====================

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInProgress(currentStep: 0)) {
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SelectUserType>(_onSelectUserType);
    on<UpdateUsername>(_onUpdateUsername);
    on<ToggleSkill>(_onToggleSkill);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  void _onNextStep(NextStep event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final maxSteps = currentState.userType == 'hustler' ? 3 : 2;

      if (currentState.currentStep < maxSteps) {
        emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
      }
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      if (currentState.currentStep > 0) {
        emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
      }
    }
  }

  void _onSelectUserType(SelectUserType event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(userType: event.userType));
    }
  }

  void _onUpdateUsername(UpdateUsername event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      emit(currentState.copyWith(username: event.username));
    }
  }

  void _onToggleSkill(ToggleSkill event, Emitter<OnboardingState> emit) {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final skills = List<String>.from(currentState.selectedSkills);

      if (skills.contains(event.skill)) {
        skills.remove(event.skill);
      } else {
        skills.add(event.skill);
      }

      emit(currentState.copyWith(selectedSkills: skills));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;

      emit(
        OnboardingSubmitting(
          currentStep: currentState.currentStep,
          userType: currentState.userType,
          username: currentState.username,
          selectedSkills: currentState.selectedSkills,
        ),
      );

      try {
        await Future.delayed(const Duration(seconds: 2));

        emit(
          OnboardingComplete(
            currentStep: currentState.currentStep,
            needsVerification: event.verifyNow,
            userType: currentState.userType,
            username: currentState.username,
            selectedSkills: currentState.selectedSkills,
          ),
        );
      } catch (e) {
        emit(
          OnboardingError(
            currentStep: currentState.currentStep,
            message: 'Failed to complete onboarding. Please try again.',
            userType: currentState.userType,
            username: currentState.username,
            selectedSkills: currentState.selectedSkills,
          ),
        );
      }
    }
  }
}

// ==================== ONBOARDING SCREEN ====================

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: const OnboardingScreenContent(),
    );
  }
}

class OnboardingScreenContent extends StatefulWidget {
  const OnboardingScreenContent({super.key});

  @override
  State<OnboardingScreenContent> createState() =>
      _OnboardingScreenContentState();
}

class _OnboardingScreenContentState extends State<OnboardingScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.currentStep == 0,
          onPopInvokedWithResult: (didPop, __) {
            if (didPop) return;
            context.read<OnboardingBloc>().add(PreviousStep());
          },
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            body: BlocConsumer<OnboardingBloc, OnboardingState>(
              listener: (context, state) {
                if (state is OnboardingComplete) {
                  if (state.needsVerification) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerificationScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Welcome to Kasi Hustle! 🎉'),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainLayout()),
                    );
                  }
                }

                if (state is OnboardingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Column(
                    children: [
                      _buildProgressBar(context, state),
                      Expanded(child: _buildStepContent(context, state)),
                      _buildNavBar(context, state),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxSteps = state.userType == 'hustler' ? 4 : 3;
    final progress = (state.currentStep + 1) / maxSteps;

    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UiText(
                text: 'Step ${state.currentStep + 1} of $maxSteps',
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
              UiText(
                text: '${(progress * 100).toInt()}%',
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VSpace.sm,
          ProgressBar(progress: progress * 100),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, OnboardingState state) {
    if (state.currentStep == 0) {
      return _SelectUserTypeStep();
    } else if (state.currentStep == 1) {
      return _EnterNameStep(formKey: _formKey, controller: _usernameController);
    } else if (state.currentStep == 2 && state.userType == 'hustler') {
      return _SelectSkillsStep();
    } else {
      return _VerificationStep();
    }
  }

  Widget _buildStepIndicator(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int maxSteps = state.userType == 'hustler' ? 4 : 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxSteps, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: Insets.xs),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: state.currentStep >= index
                ? colorScheme.primary
                : colorScheme.onPrimary,
          ),
        );
      }),
    );
  }

  Widget _buildNavBar(BuildContext context, OnboardingState state) {
    final bloc = context.read<OnboardingBloc>();
    final bool isFirstStep = state.currentStep == 0;
    final maxSteps = state.userType == 'hustler' ? 3 : 2;
    final bool isLastStep = state.currentStep == maxSteps;

    if (isLastStep) {
      return Padding(
        padding: EdgeInsets.all(Insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state is OnboardingSubmitting)
              const Center(child: StyledLoadSpinner())
            else
              Row(
                children: [
                  Expanded(
                    child: SecondaryBtn(
                      onPressed: () => bloc.add(PreviousStep()),
                      label: 'Back',
                      icon: Ionicons.chevron_back,
                    ),
                  ),
                  Spacer(),
                  PrimaryBtn(
                    onPressed: () => bloc.add(CompleteOnboarding(true)),
                    label: 'Verify Now',
                    icon: Ionicons.chevron_forward,
                    iconIsRight: true,
                  ),
                ],
              ),
            VSpace.sm,
            if (state is! OnboardingSubmitting)
              TextBtn(
                'Maybe Later',
                onPressed: () => bloc.add(CompleteOnboarding(false)),
              ),
            VSpace.med,
            _buildStepIndicator(context, state),
          ],
        ),
      );
    }

    VoidCallback? onContinuePressed;
    if (state is OnboardingInProgress) {
      switch (state.currentStep) {
        case 0:
          if (state.userType != null) {
            onContinuePressed = () => bloc.add(NextStep());
          }
          break;
        case 1:
          onContinuePressed = () {
            if (_formKey.currentState?.validate() ?? false) {
              bloc.add(UpdateUsername(_usernameController.text.trim()));
              bloc.add(NextStep());
            }
          };
          break;
        case 2: // Skills for hustler
          if (state.selectedSkills.isNotEmpty) {
            onContinuePressed = () => bloc.add(NextStep());
          }
          break;
      }
    }

    return Padding(
      padding: EdgeInsets.all(Insets.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: isFirstStep
                    ? SecondaryBtn(
                        onPressed: () {
                          // TODO: Implement logout
                        },
                        label: 'Logout',
                        icon: Ionicons.log_out_outline,
                      )
                    : SecondaryBtn(
                        onPressed: () => bloc.add(PreviousStep()),
                        label: 'Back',
                        icon: Ionicons.chevron_back,
                      ),
              ),
              Spacer(),
              PrimaryBtn(
                onPressed: onContinuePressed,
                label: 'Continue',
                icon: Ionicons.chevron_forward,
                iconIsRight: true,
              ),
            ],
          ),
          VSpace.med,
          _buildStepIndicator(context, state),
        ],
      ),
    );
  }
}

// ==================== STEP 1: SELECT USER TYPE ====================

class _SelectUserTypeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final selectedType = state.userType;

        return Padding(
          padding: EdgeInsets.all(Insets.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiText(
                text: 'Welcome to',
                style: TextStyles.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  UiText(
                    text: 'KASI ',
                    style: TextStyles.displaySmall.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  UiText(
                    text: 'HUSTLE',
                    style: TextStyles.displaySmall.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              VSpace.med,
              UiText(
                text: 'Let\'s get you started! What brings you here?',
                style: TextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
              VSpace.xl,
              VSpace.lg,
              _UserTypeCard(
                icon: Icons.construction,
                title: 'I\'m a Hustler',
                subtitle: 'Looking for jobs',
                isSelected: selectedType == 'hustler',
                onTap: () => context.read<OnboardingBloc>().add(
                  SelectUserType('hustler'),
                ),
              ),
              VSpace.lg,
              _UserTypeCard(
                icon: Icons.business_center,
                title: 'I\'m a Job Provider',
                subtitle: 'I have work to offer',
                isSelected: selectedType == 'job_provider',
                onTap: () => context.read<OnboardingBloc>().add(
                  SelectUserType('job_provider'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Insets.xl - 4), // 20
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: Corners.lgBorder,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 51),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: .1),
                borderRadius: Corners.medBorder,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                size: IconSizes.lg,
              ),
            ),
            HSpace.lg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiText(
                    text: title,
                    style: TextStyles.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  VSpace.xs,
                  UiText(
                    text: subtitle,
                    style: TextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 153),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: IconSizes.med,
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== STEP 2: ENTER USERNAME ====================

class _EnterNameStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;

  const _EnterNameStep({required this.formKey, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(Insets.xl),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UiText(
                      text: 'Choose a username',
                      style: TextStyles.headlineMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    VSpace.med,
                    UiText(
                      text: 'This is how others will know you on Kasi Hustle',
                      style: TextStyles.bodyLarge.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    VSpace.xl,
                    VSpace.lg,
                    StyledTextInput(
                      controller: controller,
                      label: 'Username',
                      hintText: 'e.g., KasiBuilder2025',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        if (value.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        return null;
                      },
                    ),
                    VSpace.xl,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Insets.lg),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: Corners.medBorder,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiText(
                            text: 'Tips for a good username:',
                            style: TextStyles.titleSmall.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          VSpace.sm,
                          _buildTip(context, '• At least 3 characters long'),
                          _buildTip(context, '• No spaces allowed'),
                          _buildTip(context, '• Can include numbers'),
                          _buildTip(
                            context,
                            '• Make it memorable and professional',
                          ),
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
    );
  }

  Widget _buildTip(BuildContext context, String tip) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: Insets.xs),
      child: UiText(
        text: tip,
        style: TextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: .6),
        ),
      ),
    );
  }
}

// ==================== STEP 3: SELECT SKILLS ====================

class _SelectSkillsStep extends StatelessWidget {
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
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(Insets.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiText(
                text: 'What are your skills?',
                style: TextStyles.headlineMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace.med,
              UiText(
                text: 'Select all skills you can offer (minimum 1)',
                style: TextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
              VSpace.xxl,
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: Insets.med,
                    runSpacing: Insets.med,
                    children: _availableSkills.map((skill) {
                      final isSelected = state.selectedSkills.contains(skill);
                      return GestureDetector(
                        onTap: () => context.read<OnboardingBloc>().add(
                          ToggleSkill(skill),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Insets.lg,
                            vertical: Insets.med,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: .2)
                                : colorScheme.surfaceContainer,
                            borderRadius: Corners.medBorder,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: .2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Padding(
                                  padding: EdgeInsets.only(right: Insets.sm),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: colorScheme.primary,
                                    size: IconSizes.sm,
                                  ),
                                ),
                              UiText(
                                text: skill,
                                style: TextStyles.bodyLarge.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== STEP 4: VERIFICATION ====================

class _VerificationStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final userType = state.userType;

        return Padding(
          padding: EdgeInsets.all(Insets.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiText(
                        text: 'One last thing...',
                        style: TextStyles.headlineMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VSpace.med,
                      UiText(
                        text: 'Get verified to unlock all features',
                        style: TextStyles.bodyLarge.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: .6),
                        ),
                      ),
                      VSpace.xl,
                      VSpace.lg,
                      Container(
                        padding: EdgeInsets.all(Insets.xl - 4), // 20
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: Corners.lgBorder,
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.77),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: colorScheme.primary,
                              size: IconSizes.xl * 1.5, // 60
                            ),
                            VSpace.lg,
                            UiText(
                              text: 'Why verify your account?',
                              style: TextStyles.titleLarge.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            VSpace.lg,
                            _buildBenefitItem(
                              context,
                              Icons.security,
                              'Build Trust',
                              userType == 'hustler'
                                  ? 'Verified hustlers are more likely to be hired.'
                                  : 'Verified providers attract more reliable hustlers.',
                            ),
                            VSpace.lg,
                            _buildBenefitItem(
                              context,
                              Icons.star,
                              'Get More Opportunities',
                              userType == 'hustler'
                                  ? 'Unlock access to all jobs on the platform.'
                                  : 'Your job posts will be highlighted to top talent.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: IconSizes.med),
        HSpace.lg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiText(
                text: title,
                style: TextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace.xs,
              UiText(
                text: subtitle,
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: .6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
