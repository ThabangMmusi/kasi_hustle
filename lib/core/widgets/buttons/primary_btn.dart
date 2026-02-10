import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';

/// A primary action button, typically using [FilledButton] as its base from Material 3.
///
/// Features:
/// - Loading state with a spinner, color-matched to button's foreground.
/// - Optional icon, which can be positioned to the right.
/// - Compact variant with reduced padding and text/icon size.
/// - Can accept a custom [child] widget instead of label/icon.
class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.child,
    this.isLoading = false,
    this.style, // Allows overriding the theme or base style
    this.isCompact = false,
    this.iconIsRight = false,
  }) : assert(
         child != null || label != null || icon != null,
         'At least one of child, label, or icon must be provided.',
       );

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final Widget? child;
  final bool isLoading;
  final ButtonStyle? style;
  final bool isCompact;
  final bool iconIsRight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    // Get the base style from the theme for FilledButton
    final ButtonStyle? themeStyle = theme.filledButtonTheme.style;
    // Merge theme style with instance style
    ButtonStyle effectiveStyle =
        themeStyle?.merge(style) ?? style ?? const ButtonStyle();

    // Add balanced padding and proper colors
    effectiveStyle = effectiveStyle.copyWith(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.med),
      ),
      foregroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surface,
      ),
    );

    TextStyle? currentTextStyle = effectiveStyle.textStyle?.resolve(
      {},
    ); // Try to get text style from merged style
    if (currentTextStyle == null &&
        themeStyle?.textStyle?.resolve({}) != null) {
      currentTextStyle = themeStyle!.textStyle!.resolve({});
    }
    currentTextStyle ??= textTheme.labelLarge;
    if (isCompact) {
      effectiveStyle = effectiveStyle.copyWith(
        padding: WidgetStatePropertyAll(
          Insets.buttonCompact,
        ), // Apply compact padding
        textStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(color: currentTextStyle?.color),
        ),
      );
    }

    // Ensure that if a shape was provided in the instance style, it takes final precedence.
    if (style?.shape != null) {
      effectiveStyle = effectiveStyle.copyWith(shape: style!.shape);
    }

    final Color? spinnerColor =
        effectiveStyle.foregroundColor?.resolve({}) ?? currentTextStyle?.color;

    if (child != null) {
      return FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: effectiveStyle,
        child: isLoading
            ? StyledLoadSpinner.small(valueColor: spinnerColor)
            : child!,
      );
    }

    // Icon-only button (and not loading, child is null, label is null)
    if (icon != null && label == null && !isLoading) {
      final double iconSize = isCompact ? IconSizes.sm : IconSizes.med;
      // Consistent padding with SecondaryBtn's icon-only approach
      final EdgeInsets iconOnlyPadding = EdgeInsets.all(
        isCompact ? Insets.xs : Insets.lg,
      );
      final double buttonDimension = iconSize + iconOnlyPadding.horizontal;

      return FilledButton(
        onPressed: onPressed,
        style: effectiveStyle.copyWith(
          padding: WidgetStatePropertyAll(iconOnlyPadding),
          minimumSize: WidgetStatePropertyAll(
            Size(buttonDimension, buttonDimension),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Icon(icon, size: iconSize),
      );
    }

    // Cases:
    // 1. isLoading is true (child is null).
    // 2. Not loading, label is present (child is null, icon may or may not be present).
    final double currentIconSize = isCompact ? IconSizes.sm : IconSizes.med;

    if (isLoading) {
      // Spinner as label, shrink icon. Use FilledButton.icon for consistent structure.
      return FilledButton.icon(
        onPressed: null,
        style: effectiveStyle,
        icon: const SizedBox.shrink(), // Consistent with SecondaryBtn
        label: StyledLoadSpinner.small(valueColor: spinnerColor),
      );
    } else {
      // Not loading. Child is null. Label is present (due to assertion and previous checks).
      if (icon != null) {
        // Icon and Label are present
        if (iconIsRight) {
          return FilledButton(
            onPressed: onPressed,
            style: effectiveStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label!),
                HSpace.sm,
                Icon(icon, size: currentIconSize),
              ],
            ),
          );
        }
        return FilledButton.icon(
          onPressed: onPressed,
          style: effectiveStyle,
          icon: Icon(icon, size: currentIconSize),
          label: Text(label!), // label is non-null here
        );
      } else {
        // Only Label is present
        return FilledButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: Text(label!), // label is non-null here
        );
      }
    }
  }
}
