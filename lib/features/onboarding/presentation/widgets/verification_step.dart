import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_state.dart';

class VerificationStep extends StatelessWidget {
  const VerificationStep({super.key});

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
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
