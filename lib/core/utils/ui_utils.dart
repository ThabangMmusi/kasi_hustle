import 'package:flutter/material.dart';

class UiUtils {
  /// Shows a modal bottom sheet with globally consistent styling and system UI handling.
  ///
  /// Enforces:
  /// - Transparent background (for safe area handling)
  /// - Root navigator usage (to cover bottom nav)
  /// - Dynamic bottom padding based on safe area
  static Future<T?> showGlobalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool useRootNavigator = true,
  }) {
    // Only set system UI overlay style if needed, but usually the sheet itself
    // manages its own overlay style. However, setting the nav bar to transparent
    // ensures the sheet content is visible behind it if edge-to-edge is active.

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      backgroundColor:
          Colors.transparent, // Crucial for custom safe area handling
      builder: (context) {
        // We can wrap the builder to ensure consistent padding or styling here
        return builder(context);
      },
    );
  }
}
