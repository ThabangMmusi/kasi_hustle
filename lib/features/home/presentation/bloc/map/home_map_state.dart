import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapStatus { initial, loading, ready, error }

class HomeMapState extends Equatable {
  final MapStatus status;
  final LatLng? userLocation;
  final Set<Marker> markers;
  final BitmapDescriptor? customIcon;
  final String? mapStyle;
  final String? errorMessage;

  const HomeMapState({
    this.status = MapStatus.initial,
    this.userLocation,
    this.markers = const {},
    this.customIcon,
    this.mapStyle,
    this.errorMessage,
  });

  HomeMapState copyWith({
    MapStatus? status,
    LatLng? userLocation,
    Set<Marker>? markers,
    BitmapDescriptor? customIcon,
    String? mapStyle,
    String? errorMessage,
  }) {
    return HomeMapState(
      status: status ?? this.status,
      userLocation: userLocation ?? this.userLocation,
      markers: markers ?? this.markers,
      customIcon: customIcon ?? this.customIcon,
      mapStyle: mapStyle ?? this.mapStyle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userLocation,
    markers,
    customIcon,
    mapStyle,
    errorMessage,
  ];
}
