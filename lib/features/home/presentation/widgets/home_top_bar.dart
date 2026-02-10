import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.slideAnim,
    required this.fadeAnim,
    required this.sheetPosition,
    required this.onMapTap,
    this.triggerHeight = 0.8,
    this.maxSheetHeight = 0.92,
  });

  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;
  final ValueNotifier<double> sheetPosition;
  final VoidCallback onMapTap;
  final double triggerHeight;
  final double maxSheetHeight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: slideAnim,
        child: FadeTransition(
          opacity: fadeAnim,
          child: ValueListenableBuilder<double>(
            valueListenable: sheetPosition,
            builder: (context, sheetPos, _) {
              final expandProgress =
                  ((sheetPos - triggerHeight) /
                          (maxSheetHeight - triggerHeight))
                      .clamp(0.0, 1.0);

              // Bolt-like behavior: Background fades in when sheet covers map
              final bool showWhiteBg = expandProgress > 0.1;

              return Container(
                color: colorScheme.surface.withValues(alpha: expandProgress),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Insets.med,
                      vertical: Insets.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Menu Button
                        FloatingActionButton.small(
                          heroTag: 'home_menu_btn',
                          elevation: showWhiteBg ? 0 : 4,
                          backgroundColor: showWhiteBg
                              ? Colors.transparent
                              : colorScheme.surface,
                          foregroundColor: colorScheme.onSurface,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: const Icon(Ionicons.menu),
                        ),

                        // Map Toggle Button
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: expandProgress > 0.5 ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: expandProgress <= 0.5,
                            child: TextButton.icon(
                              onPressed: onMapTap,
                              icon: const Icon(Ionicons.map),
                              label: UiText(
                                text: 'Map',
                                style: TextStyles.labelLarge.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: colorScheme.surfaceContainer,
                                foregroundColor: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
