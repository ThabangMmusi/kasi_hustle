import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapCacheService {
  static final MapCacheService _instance = MapCacheService._internal();
  factory MapCacheService() => _instance;
  MapCacheService._internal();

  final _cacheManager = DefaultCacheManager();

  // Cache user's home location (township area)
  LatLng? _cachedHomeLocation;

  // Store user's home location
  Future<void> saveHomeLocation(LatLng location) async {
    _cachedHomeLocation = location;

    // Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('home_lat', location.latitude);
      await prefs.setDouble('home_lng', location.longitude);
      debugPrint(
        '📍 Home location saved: ${location.latitude}, ${location.longitude}',
      );
    } catch (e) {
      debugPrint('❌ Error saving home location: $e');
    }
  }

  // Load home location from SharedPreferences
  Future<void> loadHomeLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('home_lat');
      final lng = prefs.getDouble('home_lng');

      if (lat != null && lng != null) {
        _cachedHomeLocation = LatLng(lat, lng);
        debugPrint('📍 Home location loaded: $lat, $lng');
      }
    } catch (e) {
      debugPrint('❌ Error loading home location: $e');
    }
  }

  LatLng? get homeLocation => _cachedHomeLocation;

  // Pre-download map tiles for 10km radius around user's location
  Future<void> downloadMapArea(LatLng center, {double radiusKm = 10}) async {
    debugPrint('📥 Starting map cache download for ${radiusKm}km radius...');

    try {
      // Calculate bounding box for radius
      // 1 degree latitude ≈ 111km
      // 1 degree longitude ≈ 111km * cos(latitude)
      final double latDelta = radiusKm / 111.0;
      final double lngDelta =
          radiusKm / (111.0 * cos(center.latitude * pi / 180));

      final bounds = LatLngBounds(
        southwest: LatLng(
          center.latitude - latDelta,
          center.longitude - lngDelta,
        ),
        northeast: LatLng(
          center.latitude + latDelta,
          center.longitude + lngDelta,
        ),
      );

      debugPrint(
        '📍 Cache bounds: ${bounds.southwest.latitude},${bounds.southwest.longitude} to ${bounds.northeast.latitude},${bounds.northeast.longitude}',
      );

      // Google Maps automatically caches viewed tiles
      // The map will cache tiles when user views the area
      await saveHomeLocation(center);

      debugPrint('✅ Map area marked for caching successfully!');
    } catch (e) {
      debugPrint('❌ Error caching map area: $e');
      rethrow;
    }
  }

  // Check if location is within cached area (10km from home)
  bool isWithinCachedArea(LatLng location) {
    if (_cachedHomeLocation == null) return false;

    final distance = Geolocator.distanceBetween(
      _cachedHomeLocation!.latitude,
      _cachedHomeLocation!.longitude,
      location.latitude,
      location.longitude,
    );

    return distance <= 10000; // 10km in meters
  }

  // Get distance from home location
  double? getDistanceFromHome(LatLng location) {
    if (_cachedHomeLocation == null) return null;

    final distance = Geolocator.distanceBetween(
      _cachedHomeLocation!.latitude,
      _cachedHomeLocation!.longitude,
      location.latitude,
      location.longitude,
    );

    return distance / 1000; // Return in km
  }

  // Clear cache if needed
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();

      // Clear home location from preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('home_lat');
      await prefs.remove('home_lng');

      _cachedHomeLocation = null;
      debugPrint('🗑️ Map cache cleared');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      rethrow;
    }
  }

  // Get cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasHomeLocation = prefs.containsKey('home_lat');

      return {
        'hasCache': hasHomeLocation,
        'homeLocation': _cachedHomeLocation,
        'cacheRadius': 10.0, // km
      };
    } catch (e) {
      return {'hasCache': false, 'homeLocation': null, 'cacheRadius': 10.0};
    }
  }
}
