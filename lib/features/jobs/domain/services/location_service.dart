import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Get the current user's location
  static Future<Position?> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied ||
            newPermission == LocationPermission.deniedForever) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );

    return distanceInMeters / 1000; // Convert to kilometers
  }

  /// Estimate travel time based on distance (assumes ~40 km/h average)
  static Duration estimateTravelTime(double distanceInKm) {
    final minutes = (distanceInKm / 40 * 60).ceil();
    return Duration(minutes: minutes);
  }

  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
