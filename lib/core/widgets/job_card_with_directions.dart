import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/home/presentation/widgets/job_details_bottom_sheet.dart';
import 'package:kasi_hustle/features/applications/presentation/widgets/job_direction_bottom_sheet.dart';

/// Enhanced Job Card with Direction Button
///
/// This is an example of how to add a "Get Directions" button to your existing job card.
/// You can:
/// 1. Replace your existing JobCard with this
/// 2. OR copy just the direction button part to add to your current card
class JobCardWithDirections extends StatelessWidget {
  final Job job;

  const JobCardWithDirections({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: Insets.med),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: Corners.medBorder,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Corners.medBorder,
          onTap: () {
            JobDetailsBottomSheet.show(context, job);
          },
          child: Padding(
            padding: EdgeInsets.all(Insets.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Budget Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: UiText(
                        text: job.title,
                        style: TextStyles.titleMedium,
                      ),
                    ),
                    SizedBox(width: Insets.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Insets.sm,
                        vertical: Insets.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: Corners.xsBorder,
                      ),
                      child: UiText(
                        text: 'R${job.budget.toStringAsFixed(0)}',
                        style: TextStyles.labelMedium.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                VSpace.sm,

                // Description
                Text(
                  job.description,
                  style: TextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                VSpace.med,

                // Location and Time Row
                Row(
                  children: [
                    Icon(
                      Ionicons.location_outline,
                      size: IconSizes.xs,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    HSpace.xs,
                    Expanded(
                      child: Text(
                        job.location,
                        style: TextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    HSpace.lg,
                    Icon(
                      Ionicons.time_outline,
                      size: IconSizes.xs,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    HSpace.xs,
                    UiText(
                      text: _getTimeAgo(job.createdAt),
                      style: TextStyles.bodySmall,
                    ),
                  ],
                ),

                // Required Skills (if available)
                if (job.requiredSkills.isNotEmpty) ...[
                  VSpace.sm,
                  Wrap(
                    spacing: Insets.xs,
                    runSpacing: Insets.xs,
                    children: job.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Insets.sm,
                          vertical: Insets.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: Corners.xsBorder,
                          border: Border.all(
                            color: colorScheme.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: TextStyles.labelSmall.copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                VSpace.med,

                // Action Buttons Row
                Row(
                  children: [
                    // View Details Button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          JobDetailsBottomSheet.show(context, job);
                        },
                        icon: Icon(
                          Ionicons.document_text_outline,
                          size: IconSizes.sm,
                        ),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: Insets.sm),
                        ),
                      ),
                    ),
                    HSpace.sm,
                    // 🗺️ NEW: Directions Button
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          JobDirectionBottomSheet.show(context, job);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: Insets.sm),
                          side: BorderSide(color: colorScheme.primary),
                        ),
                        child: Icon(
                          Ionicons.navigate,
                          size: IconSizes.sm,
                          color: colorScheme.primary,
                        ),
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
