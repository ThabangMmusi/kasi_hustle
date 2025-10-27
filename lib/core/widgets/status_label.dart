import 'package:flutter/material.dart';

enum StatusType { provider, application, bursary }

class StatusLabel extends StatelessWidget {
  final String status;
  final StatusType type;
  final bool isBig;

  const StatusLabel({
    super.key,
    required this.status,
    required this.type,
    this.isBig = false,
  });

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case StatusType.provider:
        switch (status) {
          case 'verified':
            return colorScheme.secondary;
          case 'pending':
            return colorScheme.tertiary;
          case 'rejected':
            return colorScheme.error;
          case 'suspended':
            return colorScheme.surface;
          default:
            return colorScheme.surface;
        }
      case StatusType.application:
        switch (status) {
          case 'approved':
            return colorScheme.secondary;
          case 'pending':
            return colorScheme.tertiary;
          case 'rejected':
            return colorScheme.error;
          case 'cancelled':
          case 'processing':
            return colorScheme.surface;
          default:
            return colorScheme.surface;
        }
      case StatusType.bursary:
        switch (status) {
          case 'open':
            return Colors.green;
          case 'closed':
            return Colors.red;
          default:
            return colorScheme.surface;
        }
    }
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case StatusType.provider:
        switch (status) {
          case 'verified':
            return colorScheme.onSecondary;
          case 'pending':
            return colorScheme.onTertiary;
          case 'rejected':
            return colorScheme.onError;
          case 'suspended':
            return colorScheme.onSurface;
          default:
            return colorScheme.onSurface;
        }
      case StatusType.application:
        switch (status) {
          case 'approved':
            return colorScheme.onSecondary;
          case 'pending':
            return colorScheme.onTertiary;
          case 'rejected':
            return colorScheme.onError;
          case 'cancelled':
          case 'processing':
            return colorScheme.onSurface;
          default:
            return colorScheme.onSurface;
        }
      case StatusType.bursary:
        switch (status) {
          case 'open':
            return Colors.white;
          case 'closed':
            return Colors.white;
          default:
            return colorScheme.onSurface;
        }
    }
  }

  IconData _getIconData() {
    switch (type) {
      case StatusType.provider:
        switch (status) {
          case 'verified':
            return Icons.check_circle_outline;
          case 'pending':
            return Icons.hourglass_empty;
          case 'rejected':
            return Icons.cancel_outlined;
          case 'suspended':
            return Icons.pause_circle_outline;
          default:
            return Icons.help_outline;
        }
      case StatusType.application:
        switch (status) {
          case 'approved':
            return Icons.check_circle_outline;
          case 'pending':
            return Icons.hourglass_empty;
          case 'rejected':
            return Icons.cancel_outlined;
          case 'cancelled':
            return Icons.do_not_disturb;
          case 'processing':
            return Icons.sync;
          default:
            return Icons.help_outline;
        }
      case StatusType.bursary:
        switch (status) {
          case 'open':
            return Icons.check_circle;
          case 'closed':
            return Icons.error_outline;
          default:
            return Icons.help_outline;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = _getBackgroundColor(context);
    final borderColor = HSLColor.fromColor(backgroundColor)
        .withLightness(
            (HSLColor.fromColor(backgroundColor).lightness - 0.1).clamp(0.0, 1.0))
        .toColor();

    final padding = isBig
        ? const EdgeInsets.symmetric(horizontal: 12.8, vertical: 6.4)
        : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
    final borderRadius = isBig ? 20.0 : 12.0;
    final iconSize = isBig ? 16.0 : 12.0;
    final textStyle = isBig
        ? TextStyle(
            color: _getTextColor(context),
            fontSize: 0.85 * 16.0,
          )
        : textTheme.labelSmall?.copyWith(
            color: _getTextColor(context),
          );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ), // Inner border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconData(),
            color: _getTextColor(context),
            size: iconSize,
          ),
          const SizedBox(width: 4.0),
          Text(
            status[0].toUpperCase() + status.substring(1).toLowerCase(),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
