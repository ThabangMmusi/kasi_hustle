import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

/// A styled [CircularProgressIndicator] with predefined sizes and theming.
class StyledLoadSpinner extends StatelessWidget {
  final double size;
  final Color? valueColor;
  final Color? backgroundColor;
  final double? strokeWidth;

  /// Default spinner.
  /// Size defaults to [IconSizes.med].
  const StyledLoadSpinner({
    super.key,
    this.size = IconSizes.med, // Default size
    this.valueColor,
    this.backgroundColor,
    this.strokeWidth,
  });

  /// A smaller spinner, typically for use inside buttons or compact spaces.
  /// Size is 75% of [IconSizes.med].
  const StyledLoadSpinner.small({
    super.key,
    this.size = IconSizes.med * 0.75, // Approx 18 if IconSizes.med is 24
    this.valueColor,
    this.backgroundColor,
    this.strokeWidth,
  });

  /// An even smaller spinner.
  /// Size is 65% of [IconSizes.med].
  const StyledLoadSpinner.verySmall({
    super.key,
    this.size = IconSizes.med * 0.65, // Approx 15.6 if IconSizes.med is 24
    this.valueColor,
    this.backgroundColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // If valueColor is not provided, default to the theme's primary color.
    // The parent widget (e.g., a button) should pass its foreground color if specific matching is needed.
    final Color effectiveValueColor = valueColor ?? colorScheme.primary;

    // Default background for the spinner track.
    // Made it slightly transparent for a common visual style.
    final Color effectiveBackgroundColor =
        backgroundColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    // Calculate stroke width based on size, ensuring it's not too thin or too thick.
    final double effectiveStrokeWidth =
        strokeWidth ?? (size / 7).clamp(2.0, 4.0);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: effectiveStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveValueColor),
        backgroundColor: effectiveBackgroundColor,
      ),
    );
  }
}
