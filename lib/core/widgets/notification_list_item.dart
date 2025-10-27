// import 'package:bursary_home_ui/bursary_home_ui.dart';
// import 'package:data_layer/data_layer.dart';
// import 'package:flutter/material.dart' hide Notification;
// import 'package:intl/intl.dart';

// class NotificationListItem extends StatefulWidget {
//   final Notification notification;
//   final VoidCallback? onTap;
//   final VoidCallback? onDelete;

//   const NotificationListItem({
//     super.key,
//     required this.notification,
//     this.onTap,
//     this.onDelete,
//   });

//   @override
//   State<NotificationListItem> createState() => _NotificationListItemState();
// }

// class _NotificationListItemState extends State<NotificationListItem> {
//   bool _isHovering = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovering = true),
//       onExit: (_) => setState(() => _isHovering = false),
//       child: Material(
//         color:
//             widget.notification.isRead
//                 ? Colors.transparent
//                 : colorScheme.primaryContainer.withValues(alpha: 0.1),
//         child: InkWell(
//           onTap: widget.onTap,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 12.0,
//             ),
//             child: Stack(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           _getIconForNotificationType(widget.notification.type),
//                           color:
//                               widget.notification.isRead
//                                   ? colorScheme.onSurfaceVariant
//                                   : colorScheme.primary,
//                           size: 18.0,
//                         ),
//                         HSpace.sm,
//                         Expanded(
//                           child: Text(
//                             widget.notification.title,
//                             style: TextStyles.bodyMedium.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   widget.notification.isRead
//                                       ? colorScheme.onSurface
//                                       : colorScheme.onSurface,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Text(
//                           _formatTimestamp(widget.notification.timestamp),
//                           style: TextStyles.bodySmall.copyWith(
//                             color: colorScheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                     VSpace.xs,
//                     Text(
//                       widget.notification.message,
//                       style: TextStyles.bodySmall.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//                 if (_isHovering)
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: theme.cardColor,
//                         borderRadius: BorderRadius.circular(Insets.med),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.1),
//                             blurRadius: 4.0,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: SecondaryBtn(
//                         icon: Icons.delete_outline,
//                         isCompact: true,
//                         onPressed: widget.onDelete,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getIconForNotificationType(NotificationType type) {
//     switch (type) {
//       case NotificationType.bursaryUpdate:
//         return Icons.school;
//       case NotificationType.applicationStatus:
//         return Icons.description;
//       case NotificationType.general:
//         return Icons.info_outline;
//     }
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return DateFormat('MMM d, yyyy').format(timestamp);
//     }
//   }
// }
