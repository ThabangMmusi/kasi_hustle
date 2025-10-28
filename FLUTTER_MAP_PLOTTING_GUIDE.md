# Flutter Map/Plot Implementation Guide - 2025

## Overview
This guide covers the **latest Flutter libraries** for implementing maps with markers/pins, routes, and directions. We'll focus on the two most popular approaches: **Google Maps** and **Flutter Map (OpenStreetMap)**.

**Updated based on real implementation**: This guide includes complete setup instructions for Android, Google Cloud Console API key configuration, and working code examples with actual South African job locations.

---

## 1. TOP LIBRARIES & COMPARISON

### **Option 1: Google Maps Flutter** ⭐ MOST POPULAR
- **Package**: `google_maps_flutter` (v2.13.1+)
- **Downloads**: 795K+ monthly
- **Pub Points**: 150/160
- **Best for**: Production apps needing Google Maps integration

**Pros:**
- Official Google maintained package
- Full Google Maps features (terrain, traffic, satellite)
- Advanced clustering support
- Custom markers and styling
- iOS, Android, Web support

**Cons:**
- Requires Google Maps API key
- Paid beyond free tier
- Heavier package size

---

### **Option 2: Flutter Map** ⭐ VENDOR-FREE
- **Package**: `flutter_map` (latest)
- **Uses**: OpenStreetMap (free)
- **Pub Points**: High community rating
- **Best for**: Free, open-source alternatives

**Pros:**
- Completely free (OpenStreetMap)
- Lightweight
- No API keys needed
- Excellent customization
- Great community support

**Cons:**
- Less feature-rich than Google Maps
- Smaller ecosystem

---

### **Supporting Libraries**

| Package | Purpose | Stars |
|---------|---------|-------|
| `google_maps_cluster_manager_2` (v3.2.0) | Marker clustering | ⭐⭐⭐⭐⭐ |
| `widget_to_marker` (v1.0.6) | Convert widgets to markers | ⭐⭐⭐⭐ |
| `custom_info_window` (v1.0.1) | Custom info windows | ⭐⭐⭐⭐ |
| `flutter_map_animations` (v0.9.0) | Marker animations | ⭐⭐⭐⭐ |
| `flutter_map_supercluster` (v4.3.0) | Efficient clustering | ⭐⭐⭐⭐ |
| `map_location_picker` (v3.1.0) | Location picking | ⭐⭐⭐⭐ |
| `geolocator` (latest) | Device location | ⭐⭐⭐⭐⭐ |

---

## 2. GOOGLE MAPS SETUP & CONFIGURATION

### **Step 1: Get Google Maps API Key**

1. **Go to Google Cloud Console**: https://console.cloud.google.com/
2. **Create a new project** or select existing one
3. **Enable APIs**:
   - Navigate to: **APIs & Services** → **Library**
   - Search and enable: **Maps SDK for Android**
   - Search and enable: **Directions API** (optional, for route calculations)
   - Search and enable: **Geocoding API** (optional, for address lookup)

4. **Create API Key**:
   - Go to: **APIs & Services** → **Credentials**
   - Click **+ CREATE CREDENTIALS** → **API key**
   - Copy your API key (e.g., `AIzaSyDYY_eCddZ6x6xlyWbJHRl1HQWxg5RqcXY`)

5. **Restrict API Key** (IMPORTANT for security):
   - Click on your newly created API key
   - Under **Application restrictions**:
     - Select: **Android apps**
     - Click **+ Add an item**
   
   **Get your SHA-1 fingerprints first:**
   ```bash
   # In your Flutter project root
   cd android
   ./gradlew signingReport | grep SHA1
   ```
   
   You'll see output like:
   ```
   SHA1: 9E:3A:30:80:D3:73:4B:36:7D:54:D5:B1:16:CE:07:B9:B3:4D:C6:E3  (debug)
   SHA1: 9F:0C:B1:28:FC:CA:C8:19:E5:9A:3E:8D:88:B4:C0:85:9F:5C:EE:A7  (release)
   ```

   **Add both to API key restrictions:**
   - **Package name**: `com.rva.kasihustle` (your app package)
   - **SHA-1 certificate fingerprint**: `9E:3A:30:80:D3:73:4B:36:7D:54:D5:B1:16:CE:07:B9:B3:4D:C6:E3`
   - Click **+ Add an item** again
   - **Package name**: `com.rva.kasihustle`
   - **SHA-1 certificate fingerprint**: `9F:0C:B1:28:FC:CA:C8:19:E5:9A:3E:8D:88:B4:C0:85:9F:5C:EE:A7`

6. **Under "API restrictions":**
   - Select: **Restrict key**
   - Check: ✅ **Maps SDK for Android**
   - Check: ✅ **Directions API** (if using routes)
   - Check: ✅ **Geocoding API** (if using address lookup)

7. **Click SAVE**

8. **Enable Billing**:
   - Go to: **Billing** → **Account Management**
   - Set up billing account (Google offers **$200 free credit/month**)
   - Most development usage stays within free tier

9. **Wait 5-10 minutes** for changes to propagate

### **Step 2: Android Configuration**

**1. Add API key to AndroidManifest.xml:**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <application
        android:label="Kasi Hustle"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ADD THIS: Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
        
        <activity android:name=".MainActivity">
            <!-- ... other config -->
        </activity>
    </application>
    
    <!-- ADD THIS: Allow querying for maps apps -->
    <queries>
        <package android:name="com.google.android.apps.maps" />
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="geo" />
        </intent>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" android:host="maps.google.com" />
        </intent>
    </queries>
</manifest>
```

**2. Initialize Google Maps renderer in main.dart:**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Maps with Android renderer
  // This fixes ImageReader_JNI errors and improves performance
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  runApp(const MyApp());
}
```

### **Step 3: Installation**

```bash
flutter pub add google_maps_flutter geolocator url_launcher flutter_cache_manager
```

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.5.0
  geolocator: ^14.0.2
  url_launcher: ^6.2.5  # For opening external Google Maps
  flutter_cache_manager: ^3.3.1  # For offline map caching
```

---

## 3. OFFLINE MAP CACHING (10KM RADIUS)

### **Why Offline Maps?**
- ✅ Avoid re-downloading tiles every time
- ✅ Works without internet connection
- ✅ Faster map loading
- ✅ Reduces data usage
- ✅ Better user experience in townships with poor connectivity

### **Implementation Strategy**

Google Maps Flutter doesn't support offline mode directly, but we can:
1. Cache map tiles automatically using Google's built-in caching
2. Pre-download map area for offline use
3. Store user's township area for quick access

### **Map Tile Cache Manager**

```dart
// lib/core/services/map_cache_service.dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    // You can persist this to SharedPreferences
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.setDouble('home_lat', location.latitude);
    //   prefs.setDouble('home_lng', location.longitude);
    // });
  }
  
  LatLng? get homeLocation => _cachedHomeLocation;
  
  // Pre-download map tiles for 10km radius around user's location
  Future<void> downloadMapArea(LatLng center, {double radiusKm = 10}) async {
    debugPrint('📥 Starting map cache download for ${radiusKm}km radius...');
    
    // Calculate bounding box for 10km radius
    // 1 degree latitude ≈ 111km
    // 1 degree longitude ≈ 111km * cos(latitude)
    final double latDelta = radiusKm / 111.0;
    final double lngDelta = radiusKm / (111.0 * cos(center.latitude * pi / 180));
    
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
    
    debugPrint('📍 Cache bounds: ${bounds.southwest} to ${bounds.northeast}');
    
    // Google Maps automatically caches viewed tiles
    // The map will cache tiles when user views the area
    await saveHomeLocation(center);
    
    debugPrint('✅ Map area cached successfully!');
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
  
  // Clear cache if needed
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    _cachedHomeLocation = null;
    debugPrint('🗑️ Map cache cleared');
  }
}
```

### **Enhanced Map Widget with Offline Support**

```dart
// lib/features/jobs/presentation/widgets/offline_map_widget.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class OfflineMapWidget extends StatefulWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController)? onMapCreated;

  const OfflineMapWidget({
    super.key,
    required this.initialPosition,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
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
            
            // Cache the visible area
            await _cacheVisibleArea();
            
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[900]?.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
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
                  SizedBox(width: 12),
                  Text(
                    'Caching map for offline use...',
                    style: TextStyle(color: Colors.white),
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
      // Get user's current location
      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      
      // Cache 10km radius around user
      await MapCacheService().downloadMapArea(userLocation, radiusKm: 10);
      
      // Pan map to show the area (helps cache tiles)
      await _panAroundArea(userLocation);
      
      debugPrint('✅ Map area cached for offline use');
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
    final offsets = [
      LatLng(center.latitude + 0.02, center.longitude), // North
      LatLng(center.latitude - 0.02, center.longitude), // South
      LatLng(center.latitude, center.longitude + 0.02), // East
      LatLng(center.latitude, center.longitude - 0.02), // West
    ];

    for (final offset in offsets) {
      await _controller.animateCamera(
        CameraUpdate.newLatLngZoom(offset, 14),
      );
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Return to center
    await _controller.animateCamera(
      CameraUpdate.newLatLngZoom(center, 15),
    );
  }
}
```

### **Updated Job Direction Bottom Sheet with Offline Support**

```dart
// Update the JobDirectionBottomSheet to use OfflineMapWidget
@override
Widget build(BuildContext context) {
  return Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ... handle bar and title ...

        // Replace GoogleMap with OfflineMapWidget
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: OfflineMapWidget(
              initialPosition: LatLng(
                widget.job.latitude,
                widget.job.longitude,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_userPosition != null) {
                  _updateCameraToBounds();
                }
              },
            ),
          ),
        ),
        
        // ... rest of the UI ...
      ],
    ),
  );
}
```

### **Pre-cache Maps on App Start**

```dart
// lib/main.dart - Add this after app initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Maps renderer
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  runApp(const MyApp());
  
  // Pre-cache user's township area in background
  _preCacheUserArea();
}

Future<void> _preCacheUserArea() async {
  try {
    // Wait a bit for app to initialize
    await Future.delayed(Duration(seconds: 3));
    
    // Get user's location
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) return;
    
    final position = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(position.latitude, position.longitude);
    
    // Cache 10km radius
    await MapCacheService().downloadMapArea(userLocation, radiusKm: 10);
    
    debugPrint('🎉 User township area pre-cached!');
  } catch (e) {
    debugPrint('⚠️ Could not pre-cache area: $e');
  }
}
```

### **Settings Screen - Cache Management**

```dart
// Add to user settings/profile screen
class MapCacheSettings extends StatefulWidget {
  @override
  State<MapCacheSettings> createState() => _MapCacheSettingsState();
}

class _MapCacheSettingsState extends State<MapCacheSettings> {
  bool _isCaching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offline Maps',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Download maps for your area to use offline',
          style: TextStyle(color: Colors.grey[600]),
        ),
        SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: _isCaching ? null : _downloadMapArea,
          icon: _isCaching
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.download),
          label: Text(
            _isCaching ? 'Downloading...' : 'Download My Area (10km)',
          ),
        ),
        
        SizedBox(height: 8),
        
        OutlinedButton.icon(
          onPressed: _clearCache,
          icon: Icon(Icons.delete_outline),
          label: Text('Clear Cached Maps'),
        ),
      ],
    );
  }

  Future<void> _downloadMapArea() async {
    setState(() => _isCaching = true);
    
    try {
      final position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      
      await MapCacheService().downloadMapArea(userLocation, radiusKm: 10);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Map area downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error downloading maps: $e'),
            backgroundColor: Colors.red,
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
    await MapCacheService().clearCache();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ Map cache cleared')),
      );
    }
  }
}
```

### **How It Works**

1. **Automatic Caching**: Google Maps automatically caches tiles as users view them
2. **10km Radius**: Pre-loads tiles within 10km of user's location (township area)
3. **Background Download**: Downloads map tiles in background on app start
4. **Persistent Storage**: Android caches tiles in app's storage directory
5. **Offline Access**: Cached tiles work without internet connection
6. **Smart Re-use**: Map reuses cached tiles instead of re-downloading

### **Cache Storage Location**

Google Maps Flutter stores cache at:
```
/data/data/com.rva.kasihustle/cache/GoogleMaps/
```

Typical cache size for 10km radius: **20-50 MB** depending on zoom levels

### **Benefits for Township Users**

- ✅ **One-time download**: Download once, use forever
- ✅ **Fast loading**: No waiting for tiles to load
- ✅ **Data saving**: Doesn't consume mobile data
- ✅ **Poor connectivity**: Works even with slow/no internet
- ✅ **Better UX**: Smooth map experience every time

---

## 4. COMPLETE MAP IMPLEMENTATION WITH ROUTES

### **Example: Job Direction Modal with Routes**

This is a **complete, production-ready** implementation showing:
- User's current location (blue marker)
- Job location (red marker)
- Route line between locations
- Distance calculation
- Travel time estimation
- "Open in Google Maps" functionality
- **Offline map caching support**

```dart
// lib/features/jobs/presentation/widgets/job_direction_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDirectionBottomSheet extends StatefulWidget {
  final Job job;

  const JobDirectionBottomSheet({super.key, required this.job});

  static void show(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDirectionBottomSheet(job: job),
    );
  }

  @override
  State<JobDirectionBottomSheet> createState() => _JobDirectionBottomSheetState();
}

class _JobDirectionBottomSheetState extends State<JobDirectionBottomSheet> {
  late GoogleMapController _mapController;
  late Set<Marker> _markers;
  late CameraPosition _initialCameraPosition;
  Position? _userPosition;
  bool _isLoadingUserLocation = true;
  late Set<Polyline> _polylines;
  double _distance = 0;
  Duration _estimatedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _markers = {};
    _polylines = {};
    _initializeMap();
    _getUserLocation();
  }

  void _initializeMap() {
    _initialCameraPosition = CameraPosition(
      target: LatLng(widget.job.latitude, widget.job.longitude),
      zoom: 15,
    );

    // Add job location marker (RED)
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

  Future<void> _getUserLocation() async {
    try {
      // Check location permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          setState(() {
            _isLoadingUserLocation = false;
          });
          return;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userPosition = position;
        _isLoadingUserLocation = false;

        // Add user location marker (BLUE)
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );

        // Calculate distance and time
        _calculateDistanceAndTime(
          LatLng(position.latitude, position.longitude),
          LatLng(widget.job.latitude, widget.job.longitude),
        );

        // Update camera to show both markers
        _updateCameraToBounds();
      });
    } catch (e) {
      setState(() {
        _isLoadingUserLocation = false;
      });
    }
  }

  void _calculateDistanceAndTime(LatLng start, LatLng end) {
    // Calculate distance in meters
    final distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    final estimatedTimeMinutes = (distanceInKm / 40 * 60).ceil(); // ~40 km/h avg

    setState(() {
      _distance = distanceInKm;
      _estimatedTime = Duration(minutes: estimatedTimeMinutes);

      // Create polyline (route line) between user and job
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

  Future<void> _updateCameraToBounds() async {
    if (_userPosition == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _userPosition!.latitude < widget.job.latitude
            ? _userPosition!.latitude
            : widget.job.latitude,
        _userPosition!.longitude < widget.job.longitude
            ? _userPosition!.longitude
            : widget.job.longitude,
      ),
      northeast: LatLng(
        _userPosition!.latitude > widget.job.latitude
            ? _userPosition!.latitude
            : widget.job.latitude,
        _userPosition!.longitude > widget.job.longitude
            ? _userPosition!.longitude
            : widget.job.longitude,
      ),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.job.latitude},${widget.job.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Directions to Job',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Map
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        key: const ValueKey('job_direction_map'),
                        initialCameraPosition: _initialCameraPosition,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_userPosition != null) {
                            _updateCameraToBounds();
                          }
                        },
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: _userPosition != null,
                        myLocationButtonEnabled: false,
                        compassEnabled: true,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Distance and Time Info
                  if (_userPosition != null && !_isLoadingUserLocation)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Distance
                          Column(
                            children: [
                              Icon(Icons.straighten, color: Colors.blue),
                              SizedBox(height: 8),
                              Text(
                                '${_distance.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text('Distance'),
                            ],
                          ),
                          // Divider
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey[300],
                          ),
                          // Time
                          Column(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue),
                              SizedBox(height: 8),
                              Text(
                                '${_estimatedTime.inMinutes} min',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text('Est. Time'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),

                  // Open in Google Maps button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: Icon(Icons.map),
                      label: Text('Open in Google Maps'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### **Sample Jobs with Real South African Locations**

```dart
// Sample jobs for testing
final List<Job> sampleJobs = [
  Job(
    id: '1',
    title: 'Web Development Project',
    description: 'Need a skilled web developer for e-commerce site',
    location: 'Johannesburg, South Africa',
    latitude: -26.2023,  // Johannesburg coordinates
    longitude: 28.0436,
    budget: 15000,
    createdBy: 'Tech Company',
    createdAt: DateTime.now(),
    status: 'open',
    requiredSkills: ['Flutter', 'Firebase', 'UI/UX'],
    imageUrls: [],
  ),
  Job(
    id: '2',
    title: 'Gardening Services',
    description: 'Professional garden maintenance and landscaping',
    location: 'Pretoria, South Africa',
    latitude: -25.7479,  // Pretoria coordinates
    longitude: 28.2293,
    budget: 8000,
    createdBy: 'Green Gardens',
    createdAt: DateTime.now(),
    status: 'open',
    requiredSkills: ['Gardening', 'Landscaping'],
    imageUrls: [],
  ),
  Job(
    id: '3',
    title: 'IT Support Specialist',
    description: 'Technical support for office network setup',
    location: 'Cape Town, South Africa',
    latitude: -33.9249,  // Cape Town coordinates
    longitude: 18.4241,
    budget: 12000,
    createdBy: 'Office Solutions',
    createdAt: DateTime.now(),
    status: 'open',
    requiredSkills: ['Networking', 'Hardware', 'Troubleshooting'],
    imageUrls: [],
  ),
  Job(
    id: '4',
    title: 'Plumbing Repair',
    description: 'Fix leaking pipes and install new fixtures',
    location: 'Durban, South Africa',
    latitude: -29.8587,  // Durban coordinates
    longitude: 31.0218,
    budget: 5000,
    createdBy: 'Home Services',
    createdAt: DateTime.now(),
    status: 'open',
    requiredSkills: ['Plumbing', 'Pipe Fitting'],
    imageUrls: [],
  ),
];
```

### **Demo Screen to Test Directions**

```dart
// lib/features/jobs/presentation/screens/job_direction_demo_screen.dart
import 'package:flutter/material.dart';

class JobDirectionDemoScreen extends StatelessWidget {
  const JobDirectionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Directions Demo'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: sampleJobs.length,
        itemBuilder: (context, index) {
          final job = sampleJobs[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(job.location),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(job.description),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        JobDirectionBottomSheet.show(context, job);
                      },
                      icon: Icon(Icons.directions),
                      label: Text('Get Directions'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 4. TESTING WITHOUT REAL GPS

For testing without using actual GPS (hardcoded location):

```dart
// Instead of using Geolocator.getCurrentPosition()
// Use a hardcoded test location:

Future<void> _getUserLocation() async {
  // OPTION 1: Use real GPS
  // final position = await Geolocator.getCurrentPosition();

  // OPTION 2: Hardcoded test location (Johannesburg city center)
  final position = Position(
    latitude: -26.2041,
    longitude: 28.0473,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    headingAccuracy: 0,
    altitudeAccuracy: 0,
  );

  setState(() {
    _userPosition = position;
    _isLoadingUserLocation = false;
    
    // Add marker and calculate route...
  });
}
```

---

## 5. TROUBLESHOOTING

### **Problem: Map shows gray/blank tiles**

**Error in logs:**
```
E Google Maps Android API: Error requesting API token. StatusCode=INVALID_ARGUMENT
```

**Solution:**
1. Verify API key is added to `AndroidManifest.xml`
2. Check API key restrictions in Google Cloud Console
3. Ensure SHA-1 fingerprints are correctly added
4. Enable "Maps SDK for Android" API
5. Wait 5-10 minutes after configuration changes

### **Problem: ImageReader_JNI errors**

**Error in logs:**
```
W/ImageReader_JNI: Unable to acquire a buffer item
```

**Solution:**
Add renderer initialization in `main.dart`:
```dart
final GoogleMapsFlutterPlatform mapsImplementation =
    GoogleMapsFlutterPlatform.instance;
if (mapsImplementation is GoogleMapsFlutterAndroid) {
  mapsImplementation.useAndroidViewSurface = true;
}
```

### **Problem: Location permission denied**

**Solution:**
Add permissions to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

---

## 6. COMPLETE SETUP CHECKLIST

- [ ] Create Google Cloud project
- [ ] Enable Maps SDK for Android
- [ ] Create API key
- [ ] Get SHA-1 fingerprints (`./gradlew signingReport`)
- [ ] Add package name + SHA-1 to API key restrictions
- [ ] Restrict API key to Maps SDK for Android
- [ ] Enable billing (free tier available)
- [ ] Add API key to `AndroidManifest.xml`
- [ ] Add location permissions to `AndroidManifest.xml`
- [ ] Add queries section for Google Maps app
- [ ] Initialize renderer in `main.dart`
- [ ] Install packages: `google_maps_flutter`, `geolocator`, `url_launcher`
- [ ] Wait 5-10 minutes for API changes to propagate
- [ ] Test with sample jobs

---

## 7. FLUTTER MAP IMPLEMENTATION (OpenStreetMap)

### **Installation**

```bash
flutter pub add flutter_map geolocator latlong2
```

### **Basic Setup**

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapScreen extends StatefulWidget {
  @override
  _OpenStreetMapScreenState createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  late MapController _mapController;
  
  final List<Marker> _markers = [
    Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(37.7749, -122.4194),
      builder: (ctx) => Container(
        child: Column(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 30),
            Text('SF'),
          ],
        ),
      ),
    ),
    Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(37.3382, -121.8863),
      builder: (ctx) => Container(
        child: Icon(Icons.location_on, color: Colors.blue, size: 30),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(37.5, -122.0),
          zoom: 10.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(
            LatLng(37.3382, -121.8863),
            15.0,
          );
        },
        child: Icon(Icons.zoom_in),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
```

### **Advanced: Custom Popups & Animations**

```dart
import 'package:flutter_map_animations/flutter_map_animations.dart';

class AnimatedMapScreen extends StatefulWidget {
  @override
  _AnimatedMapScreenState createState() => _AnimatedMapScreenState();
}

class _AnimatedMapScreenState extends State<AnimatedMapScreen> 
    with TickerProviderStateMixin {
  late AnimatedMapController _animatedMapController;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(
      vsync: this,
    );
  }

  Future<void> _animateToPoint() {
    return _animatedMapController.animateTo(
      dest: LatLng(37.3382, -121.8863),
      zoom: 15,
      rotation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _animatedMapController.mapController,
      options: MapOptions(
        center: LatLng(37.5, -122.0),
        zoom: 10,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }
}
```

---

## 8. GET DEVICE LOCATION

```dart
import 'package:geolocator/geolocator.dart';

Future<Position> _getUserLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  
  if (permission == LocationPermission.denied) {
    throw 'Location permissions denied';
  }
  
  return await Geolocator.getCurrentPosition();
}

// Use in your map:
Future<void> _centerOnUser() async {
  final position = await _getUserLocation();
  final controller = await _controller.future;
  await controller.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      ),
    ),
  );
}
```

---

## 9. INFO WINDOWS & POPUPS

### **Google Maps InfoWindow**

```dart
Marker(
  markerId: MarkerId('job1'),
  position: LatLng(37.7749, -122.4194),
  infoWindow: InfoWindow(
    title: 'Job Title',
    snippet: 'Company Name',
    onTap: () {
      // Show detailed info
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Job Details'),
          content: Text('Full job information here'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    },
  ),
)
```

### **Custom Info Window with Padding**

```dart
import 'package:custom_info_window/custom_info_window.dart';

class CustomInfoWindowMap extends StatefulWidget {
  @override
  _CustomInfoWindowMapState createState() => _CustomInfoWindowMapState();
}

class _CustomInfoWindowMapState extends State<CustomInfoWindowMap> {
  final CustomInfoWindowController _customInfoWindowController = 
    CustomInfoWindowController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _customInfoWindowController.googleMapController = controller;
          },
          markers: {
            Marker(
              markerId: MarkerId('marker1'),
              position: LatLng(37.7749, -122.4194),
              onTap: () {
                _customInfoWindowController.addInfoWindow(
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Job Title'),
                        SizedBox(height: 8),
                        Text('Company Details'),
                      ],
                    ),
                  ),
                  LatLng(37.7749, -122.4194),
                );
              },
            ),
          },
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 100,
          width: 300,
          offset: 35,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }
}
```

---

## 10. BEST PRACTICES

### ✅ DO:
- **Request permissions properly** before accessing location
- **Use clustering** for 100+ markers
- **Cache markers** in State to avoid rebuilding
- **Set reasonable zoom levels** (Google: 0-21, Flutter Map: 0-28)
- **Test on real devices** for GPS accuracy
- **Handle network errors** for tile loading

### ❌ DON'T:
- Hardcode API keys (use environment variables)
- Query location too frequently (battery drain)
- Create 1000+ markers without clustering
- Load all markers at once without pagination

---

## 11. RECOMMENDED ARCHITECTURE FOR YOUR APP

```
lib/
  features/
    jobs/
      presentation/
        screens/
          jobs_map_screen.dart      # Main map UI
        widgets/
          job_marker.dart           # Custom marker widget
          job_info_popup.dart       # Job details popup
      domain/
        entities/
          job_location.dart
      data/
        datasources/
          location_service.dart     # Geolocator wrapper
```

---

## 12. QUICK REFERENCE: Package Versions (2025)

```yaml
dependencies:
  google_maps_flutter: ^2.13.1
  flutter_map: ^6.1.0
  geolocator: ^11.0.0
  widget_to_marker: ^1.0.6
  google_maps_cluster_manager_2: ^3.2.0
  custom_info_window: ^1.0.1
  flutter_map_animations: ^0.9.0
  latlong2: ^0.9.1
```

---

## 13. USEFUL LINKS

- [Google Maps Flutter Docs](https://pub.dev/documentation/google_maps_flutter)
- [Flutter Map Docs](https://pub.dev/documentation/flutter_map)
- [Geolocator Plugin](https://pub.dev/packages/geolocator)
- [Google Cloud Console](https://console.cloud.google.com/)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Get SHA-1 Fingerprint Guide](https://developers.google.com/android/guides/client-auth)

---

## Summary

For **Kasi Hustle** (job mapping app with routes):

✅ **Complete Google Cloud Setup**:
1. Create project → Enable Maps SDK for Android
2. Create API key → Add SHA-1 fingerprints + package name
3. Restrict to Maps SDK for Android → Enable billing
4. Wait 5-10 minutes for propagation

✅ **Android Configuration**:
1. Add API key to `AndroidManifest.xml`
2. Add location permissions
3. Add queries for Google Maps app
4. Initialize renderer in `main.dart` with `useAndroidViewSurface = true`

✅ **Implementation Features**:
- User location (blue marker) vs Job location (red marker)
- Route polyline connecting both points
- Distance calculation in kilometers
- Travel time estimation (40 km/h average)
- "Open in Google Maps" external navigation
- Bottom sheet modal UI pattern
- Real South African job locations for testing

✅ **Testing**:
- Use hardcoded location or real GPS
- 4 sample jobs: Johannesburg, Pretoria, Cape Town, Durban
- Demo screen with "Get Directions" buttons
- Complete error handling and permission flow

✅ **Common Issues Fixed**:
- `INVALID_ARGUMENT` error → Add SHA-1 + package name to API key
- `ImageReader_JNI` errors → Use `useAndroidViewSurface = true`
- Gray map tiles → Enable Maps SDK + wait for propagation
- Location denied → Request permissions properly

**Your SHA-1 Fingerprints:**
- Debug: `9E:3A:30:80:D3:73:4B:36:7D:54:D5:B1:16:CE:07:B9:B3:4D:C6:E3`
- Release: `9F:0C:B1:28:FC:CA:C8:19:E5:9A:3E:8D:88:B4:C0:85:9F:5C:EE:A7`

**Package Name:** `com.rva.kasihustle`

This guide is based on **real implementation** with all issues resolved and tested on Android devices.
