import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/progress_bar.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';
import 'package:kasi_hustle/core/services/location_service.dart';
import 'package:kasi_hustle/features/auth/bloc/app_bloc.dart';
import 'package:kasi_hustle/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:kasi_hustle/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:kasi_hustle/features/onboarding/domain/usecases/create_user_profile.dart';
import 'package:kasi_hustle/features/onboarding/domain/usecases/request_verification.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:kasi_hustle/features/onboarding/presentation/widgets/select_user_type_step.dart';
import 'package:kasi_hustle/features/onboarding/presentation/widgets/enter_name_step.dart';
import 'package:kasi_hustle/features/onboarding/presentation/widgets/select_skills_step.dart';
import 'package:kasi_hustle/features/onboarding/presentation/widgets/location_step.dart';
import 'package:kasi_hustle/features/onboarding/presentation/widgets/verification_step.dart';

class OnboardingScreen extends StatelessWidget {
  final String? initialFirstName;
  final String? initialLastName;

  const OnboardingScreen({
    super.key,
    this.initialFirstName,
    this.initialLastName,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dataSource = OnboardingLocalDataSource();
    final repository = OnboardingRepositoryImpl(dataSource);
    final createUserProfile = CreateUserProfile(repository);
    final requestVerification = RequestVerification(repository);
    final locationService = LocationService();

    return BlocProvider(
      create: (context) => OnboardingBloc(
        createUserProfile: createUserProfile,
        requestVerification: requestVerification,
        locationService: locationService,
        initialFirstName: initialFirstName,
        initialLastName: initialLastName,
      ),
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill text fields with initial values from bloc state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<OnboardingBloc>().state;
      if (state.firstName != null) {
        _firstNameController.text = state.firstName!;
      }
      if (state.lastName != null) {
        _lastNameController.text = state.lastName!;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                    context.go(AppRoutes.verification);
                  } else {
                    // Show welcome message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Welcome to Kasi Hustle! 🎉',
                          style: TextStyle(color: colorScheme.onPrimary),
                        ),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    // Update AppBloc with the created profile directly (no database refetch)
                    context.read<AppBloc>().add(
                      AppProfileCreated(state.createdProfile),
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
    final maxSteps = state.userType == 'hustler' ? 5 : 4;
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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
      return const SelectUserTypeStep();
    } else if (state.currentStep == 1) {
      return EnterNameStep(
        formKey: _formKey,
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
      );
    } else if (state.currentStep == 2) {
      // Step 2: Skills for hustler, Location for business
      if (state.userType == 'hustler') {
        return SelectSkillsStep();
      } else {
        return const LocationStep();
      }
    } else if (state.currentStep == 3) {
      // Step 3: Location for hustler, Verification for business
      if (state.userType == 'hustler') {
        return const LocationStep();
      } else {
        return const VerificationStep();
      }
    } else {
      // Step 4: Verification for hustler only
      return const VerificationStep();
    }
  }

  Widget _buildStepIndicator(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int maxSteps = state.userType == 'hustler' ? 5 : 4;

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
    final maxSteps = state.userType == 'hustler' ? 4 : 3;
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
              bloc.add(
                UpdateName(
                  firstName: _firstNameController.text.trim(),
                  lastName: _lastNameController.text.trim(),
                ),
              );
              bloc.add(NextStep());
            }
          };
          break;
        case 2:
          // Step 2: Skills for hustler, Location for business
          if (state.userType == 'hustler') {
            // Hustler: Check if skills are selected
            if (state.selectedSkills.isNotEmpty) {
              onContinuePressed = () => bloc.add(NextStep());
            }
          } else {
            // Business: Check if location is selected
            if (state.locationName != null) {
              onContinuePressed = () => bloc.add(NextStep());
            }
          }
          break;
        case 3:
          // Step 3: Location for hustler, Verification for business
          if (state.userType == 'hustler') {
            // Hustler: Check if location is selected
            if (state.locationName != null) {
              onContinuePressed = () => bloc.add(NextStep());
            }
          }
          // Business goes to verification step which is handled by isLastStep
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
                          // Request logout through AppBloc
                          context.read<AppBloc>().add(AppLogoutRequested());
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
