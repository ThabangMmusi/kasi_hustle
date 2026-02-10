import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

class SkillSelectionWidget extends StatelessWidget {
  final List<String> availableSkills;
  final List<String> selectedSkills;
  final ValueChanged<String> onSkillSelected;

  const SkillSelectionWidget({
    super.key,
    required this.availableSkills,
    required this.selectedSkills,
    required this.onSkillSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: availableSkills.map((skill) {
        final isSelected = selectedSkills.contains(skill);
        return SkillChip(
          skill: skill,
          isSelected: isSelected,
          onTap: () => onSkillSelected(skill),
        );
      }).toList(),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String skill;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillChip({
    super.key,
    required this.skill,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: Corners.fullBorder,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.med,
          vertical: Insets.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainer,
          borderRadius: Corners.fullBorder,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          skill,
          style: TextStyles.labelLarge.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
