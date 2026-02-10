# Plan: Refactor Home Location Loading Logic

The goal is to improve how the Home Page loads the user's location. Instead of jumping straight to the current GPS position, which can be slow or fail, we will implement a multi-stage fallback approach:
1. Try to load the cached/last known position from the OS.
2. Use the saved location from the user's profile.
3. If no location is found or if it's outside a certain "freshness" or availability, then request the high-accuracy current position.
4. Set the location accuracy/radius to 40 meters instead of 10 meters.
5. Remove the hardcoded Johannesburg default (-26.2041, 28.0473) and ensure the map starts at the user's saved or cached location.

## User Review Required

> [!IMPORTANT]
> The "10 metres radious" mentioned in the request is interpreted as the current implicit behavior or a previous requirement. I will implement the new "40 meter radius" using `Geolocator`'s `LocationSettings` with `distanceFilter: 40`.

> [!NOTE]
> `GoogleMap` requires an `initialCameraPosition`. I will update `HomeMapView` to show a loading state until either a cached location, saved location, or Johannesburg (as absolute last fallback) is determined by the Bloc.

## Proposed Changes

### Home Map Feature

#### [MODIFY] [home_map_event.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/bloc/map/home_map_event.dart)
- Update `UpdateUserLocation` event to accept an optional `savedLocation` (LatLng).

#### [MODIFY] [home_map_bloc.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/bloc/map/home_map_bloc.dart)
- Refactor `_onUpdateUserLocation` to:
    - Get `lastKnownPosition` using `Geolocator.getLastKnownPosition()`.
    - Compare with `event.savedLocation`.
    - Use the best available location (cached vs saved).
    - If needed, request `Geolocator.getCurrentPosition()` with `distanceFilter: 40`.
- Ensure the map centers correctly on the best available location.

#### [MODIFY] [home_map_view.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/widgets/home_map_view.dart)
- Remove hardcoded Johannesburg coordinates.
- Use `userLocation` from `HomeMapState` if available for initial position.

#### [MODIFY] [home_screen.dart](file:///c:/devs/flutter/kasi_hustle/lib/features/home/presentation/screens/home_screen.dart)
- Update the `BlocListener` for `HomeBloc` to trigger `UpdateUserLocation` with the user's saved latitude/longitude once the profile is loaded.

## Verification Plan

### Manual Verification
- Run the app on an emulator/device.
- Verify that the map initially loads using cached or profile location if available.
- Check if the map updates correctly when the current location is eventually acquired.
- Verify the 40m radius behavior (if possible to test by moving).
