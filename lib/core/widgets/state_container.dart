import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

/// Reusable container for displaying loading states
class LoadingStateContainer extends StatelessWidget {
  final String message;
  final Color? backgroundColor;

  const LoadingStateContainer({
    super.key,
    required this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(Insets.med),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainer,
        borderRadius: Corners.smBorder,
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            VSpace.sm,
            UiText(
              text: message,
              style: TextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable container for displaying error states
class ErrorStateContainer extends StatelessWidget {
  final String message;
  final IconData? icon;

  const ErrorStateContainer({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(Insets.med),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: Corners.smBorder,
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Ionicons.alert_circle_outline,
            color: colorScheme.error,
            size: IconSizes.lg,
          ),
          HSpace.med,
          Expanded(
            child: UiText(
              text: message,
              style: TextStyles.bodySmall.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable container for displaying info messages
class InfoContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;

  const InfoContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(Insets.med),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainer,
        borderRadius: Corners.smBorder,
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiText(text: title, style: TextStyles.titleMedium),
          if (subtitle != null) ...[
            VSpace.sm,
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: colorScheme.onSurfaceVariant,
                    size: IconSizes.xs,
                  ),
                  HSpace.xs,
                ],
                Expanded(
                  child: UiText(
                    text: subtitle!,
                    style: TextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
