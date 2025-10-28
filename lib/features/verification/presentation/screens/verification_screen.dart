import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';
import 'package:kasi_hustle/features/verification/data/datasources/verification_data_source.dart';
import 'package:kasi_hustle/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:kasi_hustle/features/verification/domain/usecases/submit_verification_usecase.dart';
import 'package:kasi_hustle/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:kasi_hustle/features/verification/presentation/bloc/verification_event.dart';
import 'package:kasi_hustle/features/verification/presentation/bloc/verification_state.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/camera_screen.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/instructions_screen.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/preview_screen.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/verification_success_screen.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create dependencies
    final dataSource = VerificationDataSourceImpl();
    final repository = VerificationRepositoryImpl(dataSource);
    final submitVerificationUseCase = SubmitVerificationUseCase(repository);
    final userProfileService = UserProfileService();

    return BlocProvider(
      create: (context) => VerificationBloc(
        submitVerificationUseCase: submitVerificationUseCase,
        userProfileService: userProfileService,
      )..add(StartVerification()),
      child: const VerificationScreenContent(),
    );
  }
}

class VerificationScreenContent extends StatelessWidget {
  const VerificationScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        final bloc = context.read<VerificationBloc>();
        if (bloc.state.status == VerificationFlowStatus.instructions) {
          return true;
        }
        bloc.add(GoToPreviousStep());
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: BlocConsumer<VerificationBloc, VerificationState>(
          listener: (context, state) {
            if (state.status == VerificationFlowStatus.success) {
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
              Future.delayed(const Duration(seconds: 2), () {
                final userService = UserProfileService();
                final userType = userService.currentUser?.userType ?? 'hustler';
                final destination = userType == 'hustler'
                    ? AppRoutes.home
                    : AppRoutes.businessHome;
                context.go(destination);
              });
            }

            if (state.status == VerificationFlowStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case VerificationFlowStatus.instructions:
                return InstructionsScreen(
                  onCompleted: () => context.read<VerificationBloc>().add(
                    RetakeSelfie(),
                  ), // Go to selfie capture
                );
              case VerificationFlowStatus.selfieCapture:
                return CameraScreen(
                  onCaptured: (image) => context.read<VerificationBloc>().add(
                    SelfieCaptured(image),
                  ),
                  isSelfie: true,
                );
              case VerificationFlowStatus.selfiePreview:
                return PreviewScreen(
                  imageFile: state.selfieImage!,
                  onRetake: () =>
                      context.read<VerificationBloc>().add(RetakeSelfie()),
                  onConfirm: () => context.read<VerificationBloc>().add(
                    RetakeId(),
                  ), // Go to ID capture
                  confirmButtonText: 'Capture ID',
                  isSelfie: true,
                );
              case VerificationFlowStatus.idCapture:
                return CameraScreen(
                  onCaptured: (image) =>
                      context.read<VerificationBloc>().add(IdCaptured(image)),
                  isSelfie: false,
                );
              case VerificationFlowStatus.idPreview:
                return PreviewScreen(
                  imageFile: state.idImage!,
                  onRetake: () =>
                      context.read<VerificationBloc>().add(RetakeId()),
                  onConfirm: () => context.read<VerificationBloc>().add(
                    SubmitVerification(),
                  ),
                  confirmButtonText: 'Verify',
                  isSelfie: false,
                );
              case VerificationFlowStatus.uploading:
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const StyledLoadSpinner(),
                      VSpace.lg,
                      UiText(
                        text: 'Submitting verification...',
                        style: TextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              case VerificationFlowStatus.success:
                return const VerificationSuccessScreen();
              default:
                return Center(
                  child: UiText(text: 'Welcome!', style: TextStyles.titleLarge),
                );
            }
          },
        ),
      ),
    );
  }
}
