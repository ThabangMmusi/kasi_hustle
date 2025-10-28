import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/core/services/map_cache_service.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

class OfflineMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;
  final bool enableCaching;

  const OfflineMapWidget({
    super.key,
    required this.initialPosition,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.enableCaching = true,
  });

  @override
  State<OfflineMapWidget> createState() => _OfflineMapWidgetState();
}

class _OfflineMapWidgetState extends State<OfflineMapWidget> {
  late GoogleMapController _controller;
  bool _isMapReady = false;
  bool _isCachingArea = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          key: const ValueKey('offline_map'),
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) async {
            _controller = controller;
            _isMapReady = true;

            // Cache the visible area if enabled
            if (widget.enableCaching) {
              await _cacheVisibleArea();
            }

            widget.onMapCreated?.call(controller);
          },
          markers: widget.markers,
          polylines: widget.polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          // Enable offline mode features
          liteModeEnabled: false,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: true,
          trafficEnabled: false, // Disable traffic for offline
        ),

        // Caching indicator
        if (_isCachingArea)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Insets.med,
                vertical: Insets.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withValues(alpha: 0.9),
                borderRadius: Corners.xsBorder,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  HSpace.sm,
                  Text(
                    'Caching map for offline use...',
                    style: TextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _cacheVisibleArea() async {
    if (!_isMapReady) return;

    setState(() => _isCachingArea = true);

    try {
      // Check if we already have a cached home location
      final cacheService = MapCacheService();
      await cacheService.loadHomeLocation();

      if (cacheService.homeLocation == null) {
        // Get user's current location
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          // Can't cache without location permission
          debugPrint('⚠️ Location permission denied, skipping cache');
          return;
        }

        final position = await Geolocator.getCurrentPosition();
        final userLocation = LatLng(position.latitude, position.longitude);

        // Cache 10km radius around user
        await cacheService.downloadMapArea(userLocation, radiusKm: 10);

        // Pan around area to help cache tiles
        await _panAroundArea(userLocation);

        debugPrint('✅ Map area cached for offline use');
      } else {
        debugPrint('✅ Using existing cached map area');
      }
    } catch (e) {
      debugPrint('❌ Error caching map: $e');
    } finally {
      if (mounted) {
        setState(() => _isCachingArea = false);
      }
    }
  }

  // Pan around the area to help cache tiles
  Future<void> _panAroundArea(LatLng center) async {
    try {
      final offsets = [
        LatLng(center.latitude + 0.02, center.longitude), // North (~2km)
        LatLng(center.latitude - 0.02, center.longitude), // South
        LatLng(center.latitude, center.longitude + 0.02), // East
        LatLng(center.latitude, center.longitude - 0.02), // West
        LatLng(center.latitude + 0.04, center.longitude), // Far North (~4km)
        LatLng(center.latitude - 0.04, center.longitude), // Far South
        LatLng(center.latitude, center.longitude + 0.04), // Far East
        LatLng(center.latitude, center.longitude - 0.04), // Far West
      ];

      for (final offset in offsets) {
        if (!mounted) break;
        await _controller.animateCamera(CameraUpdate.newLatLngZoom(offset, 14));
        await Future.delayed(Duration(milliseconds: 300));
      }

      // Return to center
      if (mounted) {
        await _controller.animateCamera(CameraUpdate.newLatLngZoom(center, 15));
      }
    } catch (e) {
      debugPrint('❌ Error panning area: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
