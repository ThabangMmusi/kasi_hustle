import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: Insets.med),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Corners.medBorder,
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Corners.medBorder,
          onTap: () {
            // Navigate to job detail
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: UiText(text: 'Opening ${job.title}'),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(Insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: UiText(
                        text: job.title,
                        style: TextStyles.titleMedium,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Insets.sm,
                        vertical: Insets.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: Corners.smBorder,
                      ),
                      child: UiText(
                        text: 'R${job.budget.toStringAsFixed(0)}',
                        style: TextStyles.bodyMedium.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                VSpace.sm,
                Text(
                  job.description,
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                VSpace.med,
                Row(
                  children: [
                    Icon(
                      Ionicons.location_outline,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      size: IconSizes.xs,
                    ),
                    HSpace.xs,
                    UiText(
                      text: job.location,
                      style: TextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    HSpace.lg,
                    Icon(
                      Ionicons.time_outline,
                      color: colorScheme.onSurface.withOpacity(0.5),
                      size: IconSizes.xs,
                    ),
                    HSpace.xs,
                    UiText(
                      text: _getTimeAgo(job.createdAt),
                      style: TextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
