import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/core/services/map_cache_service.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class MapCacheSettings extends StatefulWidget {
  const MapCacheSettings({super.key});

  @override
  State<MapCacheSettings> createState() => _MapCacheSettingsState();
}

class _MapCacheSettingsState extends State<MapCacheSettings> {
  bool _isCaching = false;
  bool _hasCache = false;
  String? _cacheInfo;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    final cacheService = MapCacheService();
    await cacheService.loadHomeLocation();

    final info = await cacheService.getCacheInfo();

    setState(() {
      _hasCache = info['hasCache'] as bool;
      if (_hasCache && info['homeLocation'] != null) {
        final location = info['homeLocation'] as LatLng;
        _cacheInfo =
            'Cached area: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      } else {
        _cacheInfo = 'No cached area';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              Icon(Icons.map, color: colorScheme.primary, size: IconSizes.med),
              HSpace.sm,
              UiText(
                text: 'Offline Maps',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VSpace.sm,
          UiText(
            text: 'Download maps for your area to use offline and save data',
            style: TextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          VSpace.med,

          // Cache status
          Container(
            padding: EdgeInsets.all(Insets.sm),
            decoration: BoxDecoration(
              color: _hasCache
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: Corners.xsBorder,
              border: Border.all(
                color: _hasCache
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _hasCache ? Icons.check_circle : Icons.info_outline,
                  size: IconSizes.sm,
                  color: _hasCache
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                HSpace.xs,
                Expanded(
                  child: UiText(
                    text: _cacheInfo ?? 'Loading...',
                    style: TextStyles.bodySmall.copyWith(
                      color: _hasCache
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          VSpace.med,

          // Download button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCaching ? null : _downloadMapArea,
              icon: _isCaching
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.download),
              label: Text(
                _isCaching ? 'Downloading...' : 'Download My Area (10km)',
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: Insets.med),
              ),
            ),
          ),

          VSpace.sm,

          // Clear cache button
          if (_hasCache)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearCache,
                icon: Icon(Icons.delete_outline),
                label: Text('Clear Cached Maps'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: Insets.med),
                ),
              ),
            ),

          VSpace.sm,

          // Info text
          Container(
            padding: EdgeInsets.all(Insets.sm),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: Corners.xsBorder,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: IconSizes.sm,
                  color: colorScheme.onSurfaceVariant,
                ),
                HSpace.xs,
                Expanded(
                  child: UiText(
                    text:
                        'This will download about 20-50MB of map data. Your maps will work without internet after downloading.',
                    style: TextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadMapArea() async {
    setState(() => _isCaching = true);

    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission denied permanently. Please enable in settings.';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);

      // Download map area
      await MapCacheService().downloadMapArea(userLocation, radiusKm: 10);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Map area downloaded successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Reload cache info
        await _loadCacheInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error downloading maps: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCaching = false);
      }
    }
  }

  Future<void> _clearCache() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cached Maps?'),
        content: const Text(
          'This will remove downloaded map data. You can download again anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await MapCacheService().clearCache();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('🗑️ Map cache cleared')));

        // Reload cache info
        await _loadCacheInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error clearing cache: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
