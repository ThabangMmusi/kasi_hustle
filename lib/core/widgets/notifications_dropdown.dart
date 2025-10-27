// import 'package:bursary_home_ui/theme/styles.dart';
// import 'package:bursary_home_ui/widgets/notification_list_item.dart';
// import 'package:bursary_home_ui/widgets/styled_load_spinner.dart';
// import 'package:data_layer/data_layer.dart';
// import 'package:flutter/material.dart' hide Notification;

// class NotificationsDropdown extends StatelessWidget {
//   final List<Notification> notifications;
//   final bool isLoading;
//   final VoidCallback? onMarkAllRead;
//   final ValueChanged<String>? onNotificationTap;
//   final ValueChanged<String>? onNotificationDelete;

//   const NotificationsDropdown({
//     super.key,
//     required this.notifications,
//     this.isLoading = false,
//     this.onMarkAllRead,
//     this.onNotificationTap,
//     this.onNotificationDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Container(
//       constraints: const BoxConstraints(maxWidth: 350, maxHeight: 400),
//       decoration: BoxDecoration(
//         color: colorScheme.onPrimary,
//         borderRadius: Corners.smBorder,
//         boxShadow: Shadows.medium,
//         border: Border.all(
//           color: colorScheme.outline.withValues(alpha: 0.5),
//           width: Strokes.thin,
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Notifications',
//                   style: TextStyles.titleMedium.copyWith(
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 if (notifications.isNotEmpty && !isLoading)
//                   TextButton(
//                     onPressed: onMarkAllRead,
//                     child: Text(
//                       'Mark all as read',
//                       style: TextStyles.bodySmall.copyWith(
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           isLoading
//               ? const SizedBox(
//                 height: 100,
//                 child: Center(child: StyledLoadSpinner()),
//               )
//               : notifications.isEmpty
//               ? SizedBox(
//                 height: 100,
//                 child: Center(
//                   child: Text(
//                     'No new notifications',
//                     style: TextStyles.bodyMedium.copyWith(
//                       color: colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               )
//               : Expanded(
//                 child: ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: notifications.length,
//                   itemBuilder: (context, index) {
//                     final notification = notifications[index];
//                     return NotificationListItem(
//                       notification: notification,
//                       onTap: () => onNotificationTap?.call(notification.id),
//                       onDelete:
//                           () => onNotificationDelete?.call(notification.id),
//                     );
//                   },
//                 ),
//               ),
//         ],
//       ),
//     );
//   }
// }
