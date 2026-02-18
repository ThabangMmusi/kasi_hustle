import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

class StandardMenuItem extends StatelessWidget {
  const StandardMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.trailing,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? effectiveTrailing = trailing;
    if (effectiveTrailing == null && showChevron) {
      effectiveTrailing = const Icon(Ionicons.chevron_forward, size: 16);
    }

    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurface),
      title: Text(
        label,
        style: TextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: effectiveTrailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: Insets.xl),
    );
  }
}
