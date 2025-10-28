import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
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
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surfaceContainer,
          borderRadius: Corners.fullBorder,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: Insets.xs),
                child: Icon(
                  Ionicons.checkmark_circle,
                  color: colorScheme.primary,
                  size: IconSizes.xs,
                ),
              ),
            Text(
              skill,
              style: TextStyles.labelLarge.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
