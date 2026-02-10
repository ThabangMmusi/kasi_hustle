import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class BottomSheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const BottomSheetHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Ionicons.briefcase,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with job info
        Container(
          padding: EdgeInsets.all(Insets.lg),
          decoration: BoxDecoration(color: colorScheme.surface),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                  ),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimary,
                  size: IconSizes.med,
                ),
              ),
              HSpace.med,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UiText(
                      text: title,
                      style: TextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Ionicons.location_outline,
                          size: IconSizes.xs,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        HSpace.xs,
                        Expanded(
                          child: UiText(
                            text: subtitle,
                            style: TextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Ionicons.close, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
      ],
    );
  }
}
