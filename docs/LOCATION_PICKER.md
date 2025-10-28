# LocationPickerWidget Documentation

A reusable, feature-rich location picker component for selecting locations using Google Places autocomplete or GPS, with optional offline map caching.

## Overview

The `LocationPickerWidget` provides a consistent location selection experience across the app, supporting:
- 🔍 Google Places autocomplete search
- 📍 Current GPS location detection
- 💾 Optional offline map caching (10km radius)
- 🎨 Customizable UI text and behavior
- 🔄 Reactive callback system

## Location

```
lib/core/widgets/location_picker_widget.dart
```

## Basic Usage

```dart
import 'package:kasi_hustle/core/widgets/location_picker_widget.dart';

LocationPickerWidget(
  onLocationChanged: (locationData, shouldCacheOffline) {
    print('Location: ${locationData.locationName}');
    print('Lat/Lng: ${locationData.latitude}, ${locationData.longitude}');
    print('Cache offline: $shouldCacheOffline');
  },
)
```

## LocationData Model

The callback provides a `LocationData` object with:

```dart
class LocationData {
  final String locationName;  // e.g., "Soweto, Johannesburg"
  final double latitude;
  final double longitude;
  
  LatLng get latLng;  // Convenience getter for Google Maps
}
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initialLocationName` | `String?` | `null` | Pre-populate the search field with a location name |
| `showOfflineCacheToggle` | `bool` | `false` | Show/hide the offline caching toggle switch |
| `defaultCacheEnabled` | `bool` | `true` | Default state of the offline cache toggle |
| `onLocationChanged` | `Function?` | `null` | Callback when location is selected: `(LocationData, bool) → void` |
| `searchHint` | `String?` | `"Search for location"` | Placeholder text for the search field |
| `title` | `String?` | `null` | Optional title text above the search field |
| `subtitle` | `String?` | `null` | Optional subtitle/description text |

## Use Cases

### 1. Onboarding Flow (with offline caching)

Used in `lib/features/onboarding/presentation/widgets/location_step.dart`:

```dart
LocationPickerWidget(
  initialLocationName: state.locationName,
  showOfflineCacheToggle: true,
  defaultCacheEnabled: true,
  title: 'Where are you based?',
  subtitle: 'This helps us find jobs and hustlers near you.',
  searchHint: 'Search for your location',
  onLocationChanged: (locationData, shouldCacheOffline) {
    context.read<OnboardingBloc>().add(
      UpdateLocation(
        locationName: locationData.locationName,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      ),
    );
  },
)
```

**Features enabled:**
- ✅ Offline cache toggle visible
- ✅ Auto-downloads 10km map radius when location selected
- ✅ Shows progress indicator during download
- ✅ Displays success/error messages

### 2. Profile Location Update (no caching)

Future implementation for updating user profile location:

```dart
LocationPickerWidget(
  initialLocationName: user.location,
  showOfflineCacheToggle: false,  // No caching needed
  title: 'Update your location',
  subtitle: 'Where are you currently based?',
  searchHint: 'Search for your new location',
  onLocationChanged: (locationData, _) {
    profileBloc.updateLocation(
      locationData.locationName,
      locationData.latitude,
      locationData.longitude,
    );
  },
)
```

**Features enabled:**
- ✅ Simple location selection
- ❌ No offline caching
- ✅ Pre-populated with current location

### 3. Job Posting Location (no caching)

Future implementation for job location selection:

```dart
LocationPickerWidget(
  showOfflineCacheToggle: false,
  title: 'Where is this job located?',
  subtitle: 'Specify the job location to help hustlers find it',
  searchHint: 'Search for job location',
  onLocationChanged: (locationData, _) {
    jobFormBloc.setJobLocation(
      locationData.locationName,
      locationData.latLng,
    );
  },
)
```

**Features enabled:**
- ✅ Location selection for job posting
- ❌ No offline caching
- ✅ Clean, focused interface

## Features

### Google Places Autocomplete

- Country-specific search (South Africa only: `["ZA"]`)
- Auto-removes "South Africa" from location names for cleaner display
- 800ms debounce for efficient API usage
- Real-time search suggestions

### GPS Location Detection

- Requests location permissions if needed
- High accuracy GPS positioning
- Error handling for denied permissions
- Loading state indicator

### Offline Map Caching

When `showOfflineCacheToggle: true`:

1. **Toggle Switch UI:**
   - Icon: Cloud offline indicator
   - Label: "Save maps for offline use"
   - Description: "Download 10km radius for offline access"

2. **Auto-Download Behavior:**
   - Downloads map tiles when location is selected
   - Only if toggle is enabled
   - Shows progress indicator: "Downloading maps for offline use..."
   - Success message: "✅ Map saved for offline use"
   - Error handling with user-friendly messages

3. **Cache Service:**
   - Uses `MapCacheService` singleton
   - Stores tiles in app cache directory
   - 10km radius from selected location
   - Tiles available for offline use in map widgets

### Manual Re-Cache

If user toggles the switch ON after selecting a location:
- Automatically triggers cache download
- No need to re-select location

## UI Components

### Layout Structure

```
[Title] (optional)
[Subtitle] (optional)

[Google Places Search Field]
  - Icon: Search
  - Autocomplete dropdown
  - South Africa locations only

[Offline Cache Toggle] (optional)
  - Toggle switch
  - Description text
  - Icon indicator

[Progress Indicator] (when caching)
  - Circular progress
  - Status message

--- OR ---

[Use Current Location Button]
  - Secondary button style
  - GPS icon
  - Loading state
```

### Theming

All UI elements use the app's theme system:
- `Theme.of(context).colorScheme.*`
- `TextStyles.*` from core styles
- `Insets.*` for consistent spacing

## Error Handling

### Location Permission Errors

```dart
❌ Error getting location: Location permission denied
❌ Error getting location: Location permission denied permanently. Please enable in settings.
```

### Map Cache Errors

```dart
⚠️ Could not save map offline: [error details]
```

### Success Messages

```dart
✅ Map saved for offline use
```

## Dependencies

Required packages:
- `google_places_flutter` - Places autocomplete
- `geolocator` - GPS location
- `google_maps_flutter` - LatLng model
- `ionicons` - Icons

Required services:
- `MapCacheService` - Offline caching
- `EnvConfig.googlePlacesApiKey` - API key

## Implementation Notes

### State Management

The widget manages its own internal state:
- `_locationController` - Text field controller
- `_isLoadingLocation` - GPS loading indicator
- `_enableOfflineCache` - Toggle state
- `_isCachingMap` - Cache download progress
- `_currentLocation` - Last selected location

### Location Name Cleaning

Automatically removes "South Africa" suffixes:
```dart
"Soweto, Johannesburg, South Africa" → "Soweto, Johannesburg"
```

### Callback Signature

```dart
onLocationChanged: (LocationData locationData, bool shouldCacheOffline)
```

Parameters:
1. `locationData` - Selected location details
2. `shouldCacheOffline` - Current state of cache toggle (if shown)

## Best Practices

### ✅ Do:
- Use `showOfflineCacheToggle: true` only in onboarding
- Provide clear `title` and `subtitle` for context
- Handle the callback to save location data
- Use `initialLocationName` when editing existing locations

### ❌ Don't:
- Enable offline caching for temporary selections (job posting, search)
- Forget to handle permission errors
- Override the default 10km cache radius (requires service modification)

## Testing

Manual test checklist:
- [ ] Search with Google Places works
- [ ] Autocomplete suggestions appear
- [ ] Location name cleaned properly
- [ ] GPS button requests permission
- [ ] GPS location detected accurately
- [ ] Offline toggle switch functional
- [ ] Map caching triggers when enabled
- [ ] Progress indicator appears during cache
- [ ] Success message shown after cache
- [ ] Error handling for denied permissions
- [ ] Callback receives correct data
- [ ] Works in onboarding flow
- [ ] Re-selecting location updates data

## Future Enhancements

Potential improvements:
- [ ] Reverse geocoding for GPS location names (currently shows coordinates)
- [ ] Configurable cache radius (5km, 10km, 20km options)
- [ ] Cache status indicator (show if area already cached)
- [ ] Cache size estimate before download
- [ ] Cancel download option
- [ ] Multiple country support (currently ZA only)
- [ ] Map preview in widget
- [ ] Recently selected locations
- [ ] Favorite locations

## Related Documentation

- [Map Caching Service](./MAP_CACHING.md)
- [Offline Map Widget](./OFFLINE_MAP_WIDGET.md)
- [Job Direction Bottom Sheet](./JOB_DIRECTION_SHEET.md)
- [Onboarding Flow](./ONBOARDING.md)

## Support

For issues or questions:
- Check `MapCacheService` documentation for caching issues
- Verify Google Places API key is configured in `EnvConfig`
- Ensure location permissions in AndroidManifest.xml / Info.plist
- Check device location services are enabled
