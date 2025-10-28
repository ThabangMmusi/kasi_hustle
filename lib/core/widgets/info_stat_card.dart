import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

/// Reusable stat display with icon, value, and label
///
/// Used for displaying metrics like distance, time, ratings, etc.
/// Follows Bolt/Uber design pattern with icon in colored container
///
/// Example:
/// ```dart
/// InfoStatCard(
///   icon: Ionicons.navigate_outline,
///   value: '5.2 km',
///   label: 'Distance',
/// )
/// ```
class InfoStatCard extends StatelessWidget {
  /// Icon to display (e.g., navigation, time, star)
  final IconData icon;

  /// Main value to display (e.g., "5.2 km", "15 min", "4.5")
  final String value;

  /// Label below value (e.g., "Distance", "Estimated time", "Rating")
  final String label;

  /// Optional custom icon color (defaults to primary color)
  final Color? iconColor;

  /// Optional custom background color for icon (defaults to primary with 0.1 alpha)
  final Color? iconBackgroundColor;

  /// Position of the icon (left or right)
  final bool iconOnRight;

  const InfoStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.iconBackgroundColor,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveBackgroundColor =
        iconBackgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);

    final iconWidget = Container(
      padding: EdgeInsets.all(Insets.sm),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: Corners.xxlBorder,
      ),
      child: Icon(icon, color: effectiveIconColor, size: IconSizes.sm),
    );

    final textWidget = Column(
      crossAxisAlignment: iconOnRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        UiText(
          text: value,
          style: TextStyles.titleSmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        UiText(
          text: label,
          style: TextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return Expanded(
      child: Row(
        mainAxisAlignment: iconOnRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: iconOnRight
            ? [textWidget, HSpace.med, iconWidget]
            : [iconWidget, HSpace.med, textWidget],
      ),
    );
  }
}

/// Container for displaying multiple stats in a row with dividers
///
/// Example:
/// ```dart
/// InfoStatsRow(
///   stats: [
///     InfoStatCard(icon: Ionicons.navigate_outline, value: '5.2 km', label: 'Distance'),
///     InfoStatCard(icon: Ionicons.time_outline, value: '15 min', label: 'Time'),
///   ],
/// )
/// ```
class InfoStatsRow extends StatelessWidget {
  /// List of stat cards to display
  final List<InfoStatCard> stats;

  /// Whether to show dividers between stats
  final bool showDividers;

  const InfoStatsRow({
    super.key,
    required this.stats,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Insets.med,
        vertical: Insets.med,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Corners.xxlBorder,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: Shadows.universal,
      ),
      child: Row(children: _buildStatsWithDividers(colorScheme)),
    );
  }

  List<Widget> _buildStatsWithDividers(ColorScheme colorScheme) {
    final widgets = <Widget>[];

    for (int i = 0; i < stats.length; i++) {
      widgets.add(stats[i]);

      // Add divider between stats (not after last one)
      if (showDividers && i < stats.length - 1) {
        widgets.add(HSpace.med);
        widgets.add(VerticalDivider(width: 1));
        widgets.add(HSpace.med);
      } else if (!showDividers && i < stats.length - 1) {
        widgets.add(HSpace.med);
      }
    }

    return widgets;
  }
}
