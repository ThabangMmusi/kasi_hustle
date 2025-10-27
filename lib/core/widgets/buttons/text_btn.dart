import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';

class TextBtn extends StatelessWidget {
  const TextBtn(
    this.label, {
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.style,
    this.isCompact = false,
    this.showUnderline = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final bool isCompact;
  final bool showUnderline;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    ButtonStyle? baseStyle = theme.textButtonTheme.style;
    ButtonStyle effectiveStyle = baseStyle ?? const ButtonStyle();

    if (color != null) {
      effectiveStyle = effectiveStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(color),
      );
    }

    if (showUnderline) {
      effectiveStyle = effectiveStyle.copyWith(
        textStyle: WidgetStateProperty.resolveWith((states) {
          TextStyle? existingStyle =
              effectiveStyle.textStyle?.resolve(states) ??
              theme.textTheme.labelLarge;
          return existingStyle?.copyWith(
            decoration: TextDecoration.underline,
            decorationColor:
                color ??
                effectiveStyle.foregroundColor?.resolve(states) ??
                theme.colorScheme.primary,
            decorationThickness: 1.5,
          );
        }),
      );
    }

    effectiveStyle = effectiveStyle.merge(style);

    if (isCompact) {
      final EdgeInsetsGeometry currentDefaultPadding =
          effectiveStyle.padding?.resolve({}) ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      final TextStyle? currentDefaultTextStyle = effectiveStyle.textStyle
          ?.resolve({});
      effectiveStyle = effectiveStyle.copyWith(
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: (currentDefaultPadding.horizontal * 0.75).clamp(
              Insets.xs,
              Insets.sm,
            ),
            vertical: (currentDefaultPadding.vertical * 0.75).clamp(
              Insets.xs / 2,
              Insets.xs,
            ),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          (currentDefaultTextStyle ?? theme.textTheme.labelLarge)?.copyWith(
            fontSize: theme.textTheme.labelMedium?.fontSize,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: effectiveStyle,
      child: isLoading
          ? StyledLoadSpinner.verySmall(
              valueColor: effectiveStyle.foregroundColor?.resolve({}),
            )
          : Text(label),
    );
  }
}
