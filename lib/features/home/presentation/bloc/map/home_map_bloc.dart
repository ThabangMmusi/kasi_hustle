import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/utils/map_marker_helper.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_event.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_state.dart';

class HomeMapBloc extends Bloc<HomeMapEvent, HomeMapState> {
  HomeMapBloc() : super(const HomeMapState()) {
    on<InitializeMap>(_onInitializeMap);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<UpdateMapMarkers>(_onUpdateMapMarkers);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<HomeMapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.loading));

    try {
      // 1. Generate Custom Marker Icon (Needs Context for Theme/Size)
      final theme = Theme.of(event.context);
      final customIcon = await MapMarkerHelper.createCustomMarkerBitmap(
        event.context,
        icon: Ionicons.briefcase,
        color: theme.colorScheme.primary,
        iconColor: theme.colorScheme.onPrimary,
        size: 26,
      );

      // 2. Load Map Style (Optional/Placeholder)
      // String? style = await rootBundle.loadString('assets/map_styles/minimal.json');

      emit(state.copyWith(status: MapStatus.ready, customIcon: customIcon));

      // 3. Trigger Location Update
      add(UpdateUserLocation());
    } catch (e) {
      emit(
        state.copyWith(
          status: MapStatus.error,
          errorMessage: 'Failed to initialize map: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<HomeMapState> emit,
  ) async {
    try {
      // 1. Check Permissions
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          emit(state.copyWith(errorMessage: 'Location permission denied'));
          return;
        }
      }

      // 2. Try Cached Location (Last Known) first as requested
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        emit(
          state.copyWith(
            userLocation: LatLng(lastKnown.latitude, lastKnown.longitude),
          ),
        );
      }

      // 3. Use Saved Location if provided and no cached location yet
      if (state.userLocation == null && event.savedLocation != null) {
        emit(state.copyWith(userLocation: event.savedLocation));
      }

      // 4. Finally, get Current Position with 40m radius requirement
      // Using distanceFilter: 40 as requested.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 40,
        ),
      );

      emit(
        state.copyWith(
          userLocation: LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error getting location: $e'));
    }
  }

  void _onUpdateMapMarkers(UpdateMapMarkers event, Emitter<HomeMapState> emit) {
    if (state.customIcon == null) return;

    final markers = event.jobs.map((job) {
      return Marker(
        markerId: MarkerId(job.id),
        position: LatLng(job.latitude, job.longitude),
        icon:
            state.customIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: job.title, snippet: job.location),
        onTap: () {
          // Can emit a 'MarkerTapped' state if needed to open sheet
        },
      );
    }).toSet();

    emit(state.copyWith(markers: markers));
  }
}
