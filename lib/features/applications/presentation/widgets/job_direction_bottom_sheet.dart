import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/widgets/info_stat_card.dart';
import 'package:kasi_hustle/core/widgets/state_container.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/travel_mode_selector.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';
import 'package:kasi_hustle/features/applications/presentation/widgets/offline_map_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kasi_hustle/core/config/env_config.dart';
import 'package:kasi_hustle/features/applications/presentation/widgets/bottom_sheet_header.dart';

class JobDirectionBottomSheet extends StatelessWidget {
  final Job job;
  final LatLng? userLocation;

  const JobDirectionBottomSheet({
    super.key,
    required this.job,
    this.userLocation,
  });

  static void show(BuildContext context, Job job, {LatLng? userLocation}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) =>
          JobDirectionBottomSheet(job: job, userLocation: userLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JobDirectionBottomSheetContent(job: job, userLocation: userLocation);
  }
}

class JobDirectionBottomSheetContent extends StatefulWidget {
  final Job job;
  final LatLng? userLocation;

  const JobDirectionBottomSheetContent({
    super.key,
    required this.job,
    this.userLocation,
  });

  @override
  State<JobDirectionBottomSheetContent> createState() =>
      _JobDirectionBottomSheetContentState();
}

class _JobDirectionBottomSheetContentState
    extends State<JobDirectionBottomSheetContent> {
  GoogleMapController? _mapController;
  late Set<Marker> _markers;
  LatLng? _userLocation;
  bool _isLoadingUserLocation = true;
  String? _userLocationError;
  late Set<Polyline> _polylines;
  double _distance = 0;
  Duration _estimatedTime = Duration.zero;
  TravelMode _currentTravelMode = TravelMode.walk; // Start with walking

  @override
  void initState() {
    super.initState();
    _markers = {};
    _polylines = {};
    _initializeMap();
    _setUserLocation();
  }

  void _initializeMap() {
    debugPrint(
      '🗺️ Initializing map at: ${widget.job.latitude}, ${widget.job.longitude}',
    );

    // Add job location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('job_location'),
        position: LatLng(widget.job.latitude, widget.job.longitude),
        infoWindow: InfoWindow(
          title: widget.job.title,
          snippet: widget.job.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  Future<void> _setUserLocation() async {
    try {
      if (widget.userLocation != null) {
        // Use provided user location from profile
        debugPrint('📍 Using user profile location: ${widget.userLocation}');
        setState(() {
          _userLocation = widget.userLocation;
          _isLoadingUserLocation = false;

          // Add user location marker
          _markers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: _userLocation!,
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );

          // Calculate distance and time
          _calculateDistanceAndTime(
            _userLocation!,
            LatLng(widget.job.latitude, widget.job.longitude),
          );

          // Update camera to show both markers
          _updateCameraToBounds();
        });
      } else {
        setState(() {
          _isLoadingUserLocation = false;
          _userLocationError =
              'User location not available. Please update your profile location.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUserLocation = false;
        _userLocationError = 'Error: ${e.toString()}';
      });
    }
  }

  void _calculateDistanceAndTime(LatLng start, LatLng end) async {
    // Get route from Google Routes API (v2)
    try {
      final apiKey = EnvConfig.googlePlacesApiKey;
      final url = Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes',
      );

      debugPrint(
        '🚶 Calculating route with travel mode: ${_currentTravelMode.apiValue}',
      );

      // Build request body - TRAFFIC_AWARE only works for DRIVE mode
      final Map<String, dynamic> requestData = {
        'origin': {
          'location': {
            'latLng': {
              'latitude': start.latitude,
              'longitude': start.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {'latitude': end.latitude, 'longitude': end.longitude},
          },
        },
        'travelMode': _currentTravelMode.apiValue,
        'computeAlternativeRoutes': false,
        'languageCode': 'en-US',
        'units': 'METRIC',
      };

      // Only add routingPreference for DRIVE mode
      if (_currentTravelMode == TravelMode.drive) {
        requestData['routingPreference'] = 'TRAFFIC_AWARE';
        debugPrint('🚗 Adding traffic aware preference for DRIVE mode');
      } else {
        // Ensure it's not set for other modes
        requestData.remove('routingPreference');
      }

      final requestBody = json.encode(requestData);

      debugPrint('📡 Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
        body: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        debugPrint('✅ Parsed JSON data: $data');
        debugPrint('🗺️ Routes available: ${data['routes']?.length ?? 0}');

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          debugPrint('📍 Route data: $route');

          // Get accurate distance and duration from Routes API
          final distanceInMeters = route['distanceMeters']; // meters
          final durationString = route['duration']; // "123s" format
          final durationInSeconds = int.parse(
            durationString.replaceAll('s', ''),
          );

          debugPrint('📏 Distance: $distanceInMeters meters');
          debugPrint('⏱️ Duration: $durationInSeconds seconds');

          // Decode polyline for route
          final encodedPolyline = route['polyline']['encodedPolyline'];
          debugPrint('🛣️ Polyline length: ${encodedPolyline.length} chars');
          final polylinePoints = _decodePolyline(encodedPolyline);
          debugPrint('📌 Decoded ${polylinePoints.length} route points');

          if (!mounted) return;

          setState(() {
            _distance = distanceInMeters / 1000.0; // Convert to km
            _estimatedTime = Duration(seconds: durationInSeconds);

            // Create polyline with decoded route points
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylinePoints,
                color: Colors.blue,
                width: 5,
                geodesic: true,
              ),
            );
          });
          debugPrint('✅ Route updated successfully!');
          return;
        } else {
          debugPrint('❌ No routes found in response');
          // For BICYCLE mode, if no route available, use WALK data but divide time by 2
          if (_currentTravelMode == TravelMode.bicycle) {
            debugPrint(
              '⚠️ Bicycle routing not available, using walking route with adjusted time',
            );

            // Retry with WALK mode to get the route
            final walkRequestData = {
              'origin': {
                'location': {
                  'latLng': {
                    'latitude': start.latitude,
                    'longitude': start.longitude,
                  },
                },
              },
              'destination': {
                'location': {
                  'latLng': {
                    'latitude': end.latitude,
                    'longitude': end.longitude,
                  },
                },
              },
              'travelMode': 'WALK',
              'computeAlternativeRoutes': false,
              'languageCode': 'en-US',
              'units': 'METRIC',
            };

            final walkResponse = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'X-Goog-Api-Key': apiKey,
                'X-Goog-FieldMask':
                    'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
              },
              body: json.encode(walkRequestData),
            );

            if (walkResponse.statusCode == 200) {
              final walkData = json.decode(walkResponse.body);
              if (walkData['routes'] != null && walkData['routes'].isNotEmpty) {
                final walkRoute = walkData['routes'][0];
                final distanceInMeters = walkRoute['distanceMeters'];
                final walkDurationString = walkRoute['duration'];
                final walkDurationInSeconds = int.parse(
                  walkDurationString.replaceAll('s', ''),
                );

                // Cycling is roughly 2x faster than walking
                final cycleDurationInSeconds = (walkDurationInSeconds / 2)
                    .ceil();

                final encodedPolyline =
                    walkRoute['polyline']['encodedPolyline'];
                final polylinePoints = _decodePolyline(encodedPolyline);

                if (!mounted) return;

                setState(() {
                  _distance = distanceInMeters / 1000.0;
                  _estimatedTime = Duration(seconds: cycleDurationInSeconds);

                  _polylines.clear();
                  _polylines.add(
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylinePoints,
                      color: Colors.blue,
                      width: 5,
                      geodesic: true,
                    ),
                  );
                });
                debugPrint(
                  '✅ Using walking route with cycling time (${cycleDurationInSeconds}s)',
                );
                return;
              }
            }
          }
        }
      } else {
        debugPrint(
          '❌ Routes API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching route: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }

    debugPrint('⚠️ Falling back to straight-line calculation');

    // Fallback to straight line distance if API fails
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    final estimatedTimeMinutes = (distanceInKm / 40 * 60).ceil();

    if (!mounted) return;

    setState(() {
      _distance = distanceInKm;
      _estimatedTime = Duration(minutes: estimatedTimeMinutes);

      // Straight line polyline as fallback
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [start, end],
          color: Colors.blue,
          width: 5,
          geodesic: true,
        ),
      );
    });
  }

  /// Decode Google Maps polyline string to list of LatLng points
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _updateCameraToBounds() async {
    if (_userLocation == null || _mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude < widget.job.latitude
            ? _userLocation!.latitude
            : widget.job.latitude,
        _userLocation!.longitude < widget.job.longitude
            ? _userLocation!.longitude
            : widget.job.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude > widget.job.latitude
            ? _userLocation!.latitude
            : widget.job.latitude,
        _userLocation!.longitude > widget.job.longitude
            ? _userLocation!.longitude
            : widget.job.longitude,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 130),
    );
  }

  Future<void> _shareLocation() async {
    // TODO: Implement share functionality
    // You can use share_plus package or native share
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: UiText(
            text:
                'Share location: ${widget.job.title} at ${widget.job.location}',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _onTravelModeChanged(TravelMode mode) {
    setState(() {
      _currentTravelMode = mode;
    });

    // Recalculate route with new travel mode
    if (_userLocation != null) {
      _calculateDistanceAndTime(
        _userLocation!,
        LatLng(widget.job.latitude, widget.job.longitude),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Main content with map - fills entire space except header/footer
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Insets.xxxl * 2),
                  child: OfflineMapWidget(
                    initialPosition: LatLng(
                      widget.job.latitude,
                      widget.job.longitude,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    enableCaching: true,
                    onMapCreated: (controller) {
                      debugPrint('🗺️ Map created successfully!');
                      _mapController = controller;
                      if (_userLocation != null) {
                        _updateCameraToBounds();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: Insets.med),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with job info
              // Header with job info
              BottomSheetHeader(
                title: widget.job.title,
                subtitle: widget.job.location,
              ),
            ],
          ),

          // Floating stats and buttons at bottom with gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Distance and Time Info - No container
                Padding(
                  padding: EdgeInsets.all(Insets.lg),
                  child: (_userLocation != null && !_isLoadingUserLocation)
                      ? InfoStatsRow(
                          stats: [
                            InfoStatCard(
                              icon: Ionicons.navigate_outline,
                              value: '${_distance.toStringAsFixed(1)} km',
                              label: 'Distance',
                            ),

                            InfoStatCard(
                              iconOnRight: true,
                              icon: Ionicons.time_outline,
                              value: '${_estimatedTime.inMinutes} min',
                              label: 'Estimated',
                            ),
                          ],
                        )
                      : _isLoadingUserLocation
                      ? LoadingStateContainer(
                          message: 'Getting your location...',
                        )
                      : _userLocationError != null
                      ? ErrorStateContainer(message: _userLocationError!)
                      : Container(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: Shadows.universalUp,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Insets.xl),
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryBtn(
                            label: 'Close',
                            icon: Ionicons.close_outline,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        HSpace.med,
                        Expanded(
                          child: PrimaryBtn(
                            label: 'Share',
                            icon: Ionicons.share_outline,
                            onPressed: _shareLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Travel mode selector - positioned in center-right
          Positioned(
            right: (mediaQuery.size.width - 50) / 2,
            bottom: 118,
            child: TravelModeSelector(
              initialMode: _currentTravelMode,
              onModeChanged: _onTravelModeChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
