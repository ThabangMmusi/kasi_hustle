import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/widgets.dart';
import 'package:ionicons/ionicons.dart';
import '../../domain/models/application.dart';

class DirectionsScreen extends StatefulWidget {
  final Application application;

  const DirectionsScreen({super.key, required this.application});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  LatLng? jobLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDirections();
  }

  Future<void> _initializeDirections() async {
    try {
      // Get user location (job location from application)
      final List<geocoding.Location> locations = await geocoding
          .locationFromAddress(widget.application.location);

      if (locations.isNotEmpty) {
        jobLocation = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );

        // Set default user location (you can replace this with actual user location)
        userLocation = LatLng(-26.2023, 28.0436); // Johannesburg default

        _addMarkers();
        await _getDirections();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Could not find location: ${widget.application.location}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _addMarkers() {
    if (userLocation != null && jobLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('job_location'),
          position: jobLocation!,
          infoWindow: InfoWindow(title: widget.application.jobTitle),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  Future<void> _getDirections() async {
    if (userLocation == null || jobLocation == null) return;

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${userLocation!.latitude},${userLocation!.longitude}'
          '&destination=${jobLocation!.latitude},${jobLocation!.longitude}'
          '&key=AIzaSyDDEIMOIUKQoyRIyowqtDZm7JGRDuHB98Q';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final routes = json['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes[0];
          final polylinePoints = route['overview_polyline']['points'] as String;

          _decodePolyline(polylinePoints);
        }
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  void _decodePolyline(String polyline) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int result = 0, shift = 0;
      int byte;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      double latitude = (lat / 1E5);
      double longitude = (lng / 1E5);
      polylineCoordinates.add(LatLng(latitude, longitude));
    }

    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('directions'),
          points: polylineCoordinates,
          color: AppColors.kasiRed,
          width: 4,
        ),
      );
    });
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Loading...'),
          backgroundColor: AppColors.darkSurface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Error'),
          backgroundColor: AppColors.darkSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: UiText(
                  text: errorMessage!,
                  style: TextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: UiText(
          text: widget.application.jobTitle,
          style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map takes full screen
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: jobLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              if (userLocation != null && jobLocation != null) {
                final bounds = LatLngBounds(
                  southwest: LatLng(
                    userLocation!.latitude < jobLocation!.latitude
                        ? userLocation!.latitude
                        : jobLocation!.latitude,
                    userLocation!.longitude < jobLocation!.longitude
                        ? userLocation!.longitude
                        : jobLocation!.longitude,
                  ),
                  northeast: LatLng(
                    userLocation!.latitude > jobLocation!.latitude
                        ? userLocation!.latitude
                        : jobLocation!.latitude,
                    userLocation!.longitude > jobLocation!.longitude
                        ? userLocation!.longitude
                        : jobLocation!.longitude,
                  ),
                );
                mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds, 100),
                );
              }
            },
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Location info card at bottom
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Ionicons.location,
                        color: AppColors.kasiRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UiText(
                          text: widget.application.location,
                          style: TextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (jobLocation != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Ionicons.code_outline,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: UiText(
                            text:
                                '${jobLocation!.latitude.toStringAsFixed(4)}, ${jobLocation!.longitude.toStringAsFixed(4)}',
                            style: TextStyles.labelSmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
