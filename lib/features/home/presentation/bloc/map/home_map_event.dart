import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/features/home/domain/models/job.dart';

abstract class HomeMapEvent extends Equatable {
  const HomeMapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends HomeMapEvent {
  final BuildContext context;
  const InitializeMap(this.context);

  @override
  List<Object?> get props => [];
}

class UpdateUserLocation extends HomeMapEvent {
  final LatLng? savedLocation;

  const UpdateUserLocation({this.savedLocation});

  @override
  List<Object?> get props => [savedLocation];
}

class UpdateMapMarkers extends HomeMapEvent {
  final List<Job> jobs;

  const UpdateMapMarkers(this.jobs);

  @override
  List<Object?> get props => [jobs];
}
