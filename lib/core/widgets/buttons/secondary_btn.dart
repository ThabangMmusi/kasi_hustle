import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';

class SecondaryBtn extends StatelessWidget {
  const SecondaryBtn({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.child,
    this.isLoading = false,
    this.style,
    this.isCompact = false,
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    // Get the base style from the theme for OutlinedButton
    final ButtonStyle? themeStyle = theme.outlinedButtonTheme.style;
    ButtonStyle effectiveStyle =
        themeStyle?.merge(style) ?? style ?? const ButtonStyle();

    // Add rounded corners and balanced padding
    effectiveStyle = effectiveStyle.copyWith(
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Corners.xl)),
      ),
      padding: MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.med),
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
      return OutlinedButton(
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
      EdgeInsets iconOnlyPadding = EdgeInsets.all(
        isCompact ? Insets.sm : Insets.med,
      );
      // Ensure that if a shape was provided in the instance style, it takes final precedence.
      if (style?.padding != null) {
        iconOnlyPadding =
            (style!.padding?.resolve({}) ?? EdgeInsets.zero) as EdgeInsets;
      }

      final double buttonDimension = iconSize + iconOnlyPadding.horizontal;

      return IconButton.outlined(
        onPressed: onPressed,
        style: effectiveStyle.copyWith(
          padding: WidgetStatePropertyAll(iconOnlyPadding),
          minimumSize: WidgetStatePropertyAll(
            Size(buttonDimension, buttonDimension),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(icon, size: iconSize),
      );
    }

    if (child != null) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: effectiveStyle,
        child: isLoading
            ? StyledLoadSpinner.small(valueColor: spinnerColor)
            : child!,
      );
    }

    // Icon-only button (and not loading, child is null, label is null)
    if (icon != null && label == null && !isLoading) {
      final double iconSize = isCompact
          ? IconSizes.sm
          : IconSizes.med; // Match PrimaryBtn
      final EdgeInsets iconOnlyPadding = EdgeInsets.all(
        isCompact ? Insets.xs : Insets.lg,
      ); // Match PrimaryBtn
      final double buttonDimension = iconSize + iconOnlyPadding.horizontal;

      return OutlinedButton(
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
    final double currentIconSize = isCompact
        ? IconSizes.sm
        : IconSizes.med; // Match PrimaryBtn

    if (isLoading) {
      return OutlinedButton.icon(
        onPressed: null,
        style: effectiveStyle,
        icon: const SizedBox.shrink(),
        label: StyledLoadSpinner.small(valueColor: spinnerColor),
      );
    } else {
      if (icon != null) {
        return OutlinedButton.icon(
          onPressed: onPressed,
          style: effectiveStyle,
          icon: Icon(icon, size: currentIconSize),
          label: Text(label!), // label is non-null here
        );
      } else {
        return OutlinedButton(
          onPressed: onPressed,
          style: effectiveStyle,
          child: Text(label!), // label is non-null here
        );
      }
    }
  }
}
