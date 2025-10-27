import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';

class SelectableBtn extends StatelessWidget {
  const SelectableBtn({
    super.key,
    required this.onPressed,
    required this.label,
    required this.isSelected,
    this.isLoading = false,
    this.style,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isSelected;
  final bool isLoading;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    ButtonStyle currentStyle;

    if (isSelected) {
      final ButtonStyle? baseSelectedStyle = theme.filledButtonTheme.style;
      currentStyle = (baseSelectedStyle ?? const ButtonStyle()).copyWith(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(theme.colorScheme.onPrimary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.xl),
          ),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.med),
        ),
      );
    } else {
      final ButtonStyle? baseUnselectedStyle = theme.outlinedButtonTheme.style;
      currentStyle = (baseUnselectedStyle ?? const ButtonStyle()).copyWith(
        foregroundColor: WidgetStateProperty.all(
          theme.colorScheme.onSurfaceVariant,
        ),
        side: WidgetStateProperty.all(
          BorderSide(color: theme.colorScheme.outline),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.xl),
          ),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: Insets.lg, vertical: Insets.med),
        ),
      );
    }

    if (style != null) {
      currentStyle = currentStyle.merge(style);
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    return TextButton(
      onPressed: effectiveOnPressed,
      style: currentStyle,
      child: isLoading
          ? StyledLoadSpinner.small(
              valueColor:
                  currentStyle.foregroundColor?.resolve({}) ??
                  (isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant),
            )
          : Text(label),
    );
  }
}
