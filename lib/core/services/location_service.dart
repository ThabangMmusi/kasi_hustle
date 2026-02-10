import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:kasi_hustle/core/config/env_config.dart';
import 'dart:convert';

class LocationData {
  final String locationName;
  final double latitude;
  final double longitude;

  LocationData({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  /// Gets the current device location and converts it to a readable address using Google Places API
  Future<LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable location services.',
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in settings.',
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Try geocoding package first (faster, local service)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final locationName = _formatLocationFromPlacemark(placemark);

          return LocationData(
            locationName: locationName,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      } catch (geocodingError) {
        // Silently fail to fallback
      }

      // Fallback to Google Places API (slower but more accurate)
      try {
        final locationName =
            await _getAddressFromCoordinates(
              position.latitude,
              position.longitude,
            ).timeout(
              const Duration(seconds: 5),
              onTimeout: () => throw Exception('Google Places API timeout'),
            );

        return LocationData(
          locationName: locationName,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        // If all else fails, return coordinates as string
        return LocationData(
          locationName:
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Use Google Places API Geocoding to convert coordinates to address
  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final apiKey = EnvConfig.googlePlacesApiKey;

    if (apiKey.isEmpty) {
      throw Exception('Google Places API key is not configured in .env file');
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          // Get the formatted address from the first result
          final formattedAddress = data['results'][0]['formatted_address'];
          return _simplifyAddress(formattedAddress);
        } else if (data['status'] == 'REQUEST_DENIED') {
          throw Exception('Google Places API key is invalid or not enabled');
        } else {
          throw Exception(
            'No address found for coordinates (${data['status']})',
          );
        }
      } else {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting address from Google Places API: $e');
    }
  }

  /// Simplify address to show only city and province/state
  String _simplifyAddress(String formattedAddress) {
    // Remove 'South Africa' from the end if present
    formattedAddress = formattedAddress.replaceAll(', South Africa', '');
    formattedAddress = formattedAddress.replaceAll(',South Africa', '');

    // Split by comma and take relevant parts
    final parts = formattedAddress.split(',').map((e) => e.trim()).toList();

    // For South Africa addresses: "Street, Suburb, City, Postal"
    // We want: "Suburb, City" or "Street, Suburb, City"
    if (parts.length >= 4) {
      // Show first 3 parts: "Street, Suburb, City"
      return '${parts[0]}, ${parts[1]}, ${parts[2]}';
    } else if (parts.length >= 3) {
      // Show 2 parts: "Suburb, City"
      return '${parts[0]}, ${parts[1]}';
    } else if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    } else {
      return formattedAddress;
    }
  }

  /// Format location name from Placemark (fallback method)
  String _formatLocationFromPlacemark(Placemark placemark) {
    List<String> parts = [];

    // Add street or thoroughfare if available
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    } else if (placemark.thoroughfare != null &&
        placemark.thoroughfare!.isNotEmpty) {
      parts.add(placemark.thoroughfare!);
    }

    // Add sublocality (suburb/neighborhood)
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }

    // Add locality (city)
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }

    // Limit to first 3 parts for consistency with Google Places format
    if (parts.length > 3) {
      parts = parts.sublist(0, 3);
    }

    // Remove 'South Africa' if it's in any of the parts
    parts = parts.where((part) => part != 'South Africa').toList();

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }
}
