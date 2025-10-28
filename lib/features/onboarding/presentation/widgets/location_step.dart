import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/location_picker_widget.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:kasi_hustle/features/onboarding/presentation/bloc/onboarding_event.dart';

class LocationStep extends StatelessWidget {
  const LocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<OnboardingBloc>().state;

    return Padding(
      padding: EdgeInsets.all(Insets.xl),
      child: LocationPickerWidget(
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
      ),
    );
  }
}
