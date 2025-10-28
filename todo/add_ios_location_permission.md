# To-Do: Add iOS Location Permission

Add the `NSLocationWhenInUseUsageDescription` key to the `ios/Runner/Info.plist` file with a descriptive string to explain why the app needs location access. This is required for the `geolocator` and `geocoding` packages to work on iOS.

**Example:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show you nearby jobs and hustlers.</string>
```
