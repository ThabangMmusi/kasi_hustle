import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/config/env_config.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/services/map_cache_service.dart';

/// Model to hold location data
class LocationData {
  final String locationName;
  final double latitude;
  final double longitude;

  LocationData({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}

/// Reusable location picker widget with optional offline caching
///
/// Usage:
/// ```dart
/// LocationPickerWidget(
///   initialLocationName: 'Soweto',
///   showOfflineCacheToggle: true,
///   onLocationChanged: (locationData, shouldCache) {
///     // Handle location change
///   },
/// )
/// ```
class LocationPickerWidget extends StatefulWidget {
  /// Initial location name to display in text field
  final String? initialLocationName;

  /// Whether to show the offline cache toggle switch
  final bool showOfflineCacheToggle;

  /// Whether offline caching is enabled by default
  final bool defaultCacheEnabled;

  /// Callback when location changes
  /// Parameters: (locationData, shouldCacheOffline)
  final Function(LocationData locationData, bool shouldCacheOffline)?
  onLocationChanged;

  /// Optional hint text for search field
  final String? searchHint;

  /// Optional title text
  final String? title;

  /// Optional subtitle text
  final String? subtitle;

  const LocationPickerWidget({
    super.key,
    this.initialLocationName,
    this.showOfflineCacheToggle = false,
    this.defaultCacheEnabled = true,
    this.onLocationChanged,
    this.searchHint,
    this.title,
    this.subtitle,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  late TextEditingController _locationController;
  bool _isLoadingLocation = false;
  bool _enableOfflineCache = true;
  bool _isCachingMap = false;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.initialLocationName,
    );
    _enableOfflineCache = widget.defaultCacheEnabled;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  /// Handle location selection from search or GPS
  Future<void> _handleLocationSelected(LocationData locationData) async {
    setState(() {
      _currentLocation = locationData;
      _locationController.text = locationData.locationName;
    });

    // Cache map if enabled
    if (widget.showOfflineCacheToggle && _enableOfflineCache) {
      await _cacheMapArea(locationData.latLng);
    }

    // Notify parent
    widget.onLocationChanged?.call(locationData, _enableOfflineCache);
  }

  /// Cache map area for offline use
  Future<void> _cacheMapArea(LatLng location) async {
    setState(() => _isCachingMap = true);

    try {
      await MapCacheService().downloadMapArea(location, radiusKm: 10);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Map saved for offline use'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Could not save map offline: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCachingMap = false);
      }
    }
  }

  /// Get current GPS location
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission denied permanently. Please enable in settings.';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get location name (simplified - you can use a geocoding service)
      final locationName =
          'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

      final locationData = LocationData(
        locationName: locationName,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      await _handleLocationSelected(locationData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error getting location: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  /// Clean location name by removing "South Africa"
  String _cleanLocationName(String name) {
    return name
        .replaceAll(', South Africa', '')
        .replaceAll(',South Africa', '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final googleApiKey = EnvConfig.googlePlacesApiKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        if (widget.title != null) ...[
          UiText(
            text: widget.title!,
            style: TextStyles.headlineMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          VSpace.med,
        ],

        // Subtitle
        if (widget.subtitle != null) ...[
          UiText(
            text: widget.subtitle!,
            style: TextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          VSpace.xl,
        ],

        // Search Bar
        GooglePlaceAutoCompleteTextField(
          textEditingController: _locationController,
          googleAPIKey: googleApiKey,
          inputDecoration: InputDecoration(
            hintText: widget.searchHint ?? "Search for location",
            prefixIcon: const Icon(Ionicons.search),
            filled: theme.inputDecorationTheme.filled,
            fillColor: theme.inputDecorationTheme.fillColor,
            hintStyle: theme.inputDecorationTheme.hintStyle,
            border: theme.inputDecorationTheme.border,
            enabledBorder: theme.inputDecorationTheme.enabledBorder,
            focusedBorder: theme.inputDecorationTheme.focusedBorder,
          ),
          debounceTime: 800,
          countries: const ["ZA"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (prediction) {
            final locationName = _cleanLocationName(
              prediction.description ?? "Unknown Location",
            );

            final locationData = LocationData(
              locationName: locationName,
              latitude: double.tryParse(prediction.lat ?? "0.0") ?? 0.0,
              longitude: double.tryParse(prediction.lng ?? "0.0") ?? 0.0,
            );

            _handleLocationSelected(locationData);
          },
          itemClick: (prediction) {
            final locationName = _cleanLocationName(
              prediction.description ?? "Unknown Location",
            );

            final locationData = LocationData(
              locationName: locationName,
              latitude: double.tryParse(prediction.lat ?? "0.0") ?? 0.0,
              longitude: double.tryParse(prediction.lng ?? "0.0") ?? 0.0,
            );

            _handleLocationSelected(locationData);
          },
          boxDecoration: const BoxDecoration(),
          seperatedBuilder: const Divider(),
          itemBuilder: (context, index, prediction) {
            final locationName = _cleanLocationName(
              prediction.description ?? "Unknown Location",
            );

            return Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Text(locationName),
            );
          },
        ),

        VSpace.lg,

        // Offline Cache Toggle (if enabled)
        if (widget.showOfflineCacheToggle) ...[
          Container(
            padding: EdgeInsets.all(Insets.med),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Ionicons.cloud_offline_outline,
                  size: 24,
                  color: colorScheme.primary,
                ),
                HSpace.med,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiText(
                        text: 'Save maps for offline use',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      VSpace.xs,
                      UiText(
                        text: 'Download 10km radius for offline access',
                        style: TextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enableOfflineCache,
                  onChanged: (value) {
                    setState(() => _enableOfflineCache = value);

                    // If enabled and location already selected, cache now
                    if (value && _currentLocation != null) {
                      _cacheMapArea(_currentLocation!.latLng);
                    }
                  },
                ),
              ],
            ),
          ),
          VSpace.lg,
        ],

        // Caching progress indicator
        if (_isCachingMap) ...[
          Container(
            padding: EdgeInsets.all(Insets.med),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                HSpace.med,
                Expanded(
                  child: UiText(
                    text: 'Downloading maps for offline use...',
                    style: TextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VSpace.lg,
        ],

        // "OR" divider
        Row(
          children: [
            Expanded(
              child: Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.sm),
              child: UiText(
                text: "OR",
                style: TextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
          ],
        ),
        VSpace.lg,

        // Get Current Location Button
        SizedBox(
          width: double.infinity,
          child: SecondaryBtn(
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            icon: _isLoadingLocation ? null : Ionicons.navigate,
            label: _isLoadingLocation
                ? 'Getting Location...'
                : 'Use Current Location',
            isLoading: _isLoadingLocation,
          ),
        ),
      ],
    );
  }
}
