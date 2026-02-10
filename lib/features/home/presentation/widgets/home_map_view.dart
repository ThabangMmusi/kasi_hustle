import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_bloc.dart';
import 'package:kasi_hustle/features/home/presentation/bloc/map/home_map_state.dart';

class HomeMapView extends StatefulWidget {
  const HomeMapView({super.key});

  @override
  State<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeMapBloc, HomeMapState>(
      listenWhen: (previous, current) {
        return previous.userLocation != current.userLocation &&
            current.userLocation != null;
      },
      listener: (context, state) {
        if (_mapController != null && state.userLocation != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: state.userLocation!, zoom: 14),
            ),
          );
        }
      },
      child: BlocBuilder<HomeMapBloc, HomeMapState>(
        buildWhen: (previous, current) {
          return previous.markers != current.markers ||
              previous.mapStyle != current.mapStyle ||
              previous.userLocation != current.userLocation;
        },
        builder: (context, mapState) {
          if (mapState.userLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapState.userLocation!,
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.5,
            ),
            markers: mapState.markers,
            style: mapState.mapStyle,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          );
        },
      ),
    );
  }
}
