import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/bloc/theme/theme_bloc.dart';
import 'package:kasi_hustle/core/bloc/theme/theme_event.dart';
import 'package:kasi_hustle/core/bloc/theme/theme_state.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/profile/presentation/widgets/map_cache_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: UiText(
          text: 'Settings',
          style: TextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Ionicons.chevron_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(Insets.lg),
        children: [
          UiText(
            text: 'Appearance',
            style: TextStyles.titleSmall.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          VSpace.med,
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.all(Insets.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: Corners.medBorder,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.themeMode == ThemeMode.system
                              ? Icons.settings_brightness
                              : state.themeMode == ThemeMode.light
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: colorScheme.primary,
                          size: IconSizes.med,
                        ),
                        HSpace.sm,
                        UiText(
                          text: 'Theme Mode',
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    VSpace.sm,
                    UiText(
                      text: 'Personalize how Kasi Hustle looks on your device',
                      style: TextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    VSpace.lg,
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_outlined),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_outlined),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.settings_brightness_outlined),
                          ),
                        ],
                        selected: <ThemeMode>{state.themeMode},
                        onSelectionChanged: (Set<ThemeMode> newSelection) {
                          context.read<ThemeBloc>().add(
                            ThemeChanged(newSelection.first),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          VSpace.xl,

          UiText(
            text: 'Map Settings',
            style: TextStyles.titleSmall.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          VSpace.med,
          const MapCacheSettings(),
          VSpace.xl,

          // Additional settings sections can be added here in the future
          UiText(
            text: 'App Version',
            style: TextStyles.labelSmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          UiText(
            text: '1.0.0',
            style: TextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
