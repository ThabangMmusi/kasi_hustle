import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/skill_selection_widget.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_state.dart';

class SelectSkillsStep extends StatelessWidget {
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

  SelectSkillsStep({super.key});

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
                text: 'Select up to 5 skills you\'re best at.',
                style: TextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              VSpace.xxl,
              Expanded(
                child: SingleChildScrollView(
                  child: SkillSelectionWidget(
                    availableSkills: _availableSkills,
                    selectedSkills: state.selectedSkills,
                    onSkillSelected: (skill) {
                      context.read<OnboardingBloc>().add(ToggleSkill(skill));
                    },
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
