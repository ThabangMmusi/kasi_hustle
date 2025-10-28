import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_state.dart';

class SelectUserTypeStep extends StatelessWidget {
  const SelectUserTypeStep({super.key});

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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              VSpace.xl,
              VSpace.lg,
              UserTypeCard(
                icon: Icons.construction,
                title: 'I\'m a Hustler',
                subtitle: 'Looking for jobs',
                isSelected: selectedType == 'hustler',
                onTap: () => context.read<OnboardingBloc>().add(
                  SelectUserType('hustler'),
                ),
              ),
              VSpace.lg,
              UserTypeCard(
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

class UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const UserTypeCard({
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
                : colorScheme.outline.withValues(alpha: 0.2),
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
                    : colorScheme.onSurface.withValues(alpha: 0.1),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
