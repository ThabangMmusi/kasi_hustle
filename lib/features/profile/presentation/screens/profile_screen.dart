import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_load_spinner.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_state.dart';
import 'package:kasi_hustle/features/profile/presentation/screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreenContent();
  }
}

class ProfileScreenContent extends StatefulWidget {
  const ProfileScreenContent({super.key});

  @override
  State<ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<ProfileScreenContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: StyledLoadSpinner());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Ionicons.alert_circle_outline,
                    color: colorScheme.error,
                    size: IconSizes.xl,
                  ),
                  VSpace.lg,
                  UiText(
                    text: state.message,
                    style: TextStyles.bodyLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  VSpace.lg,
                  PrimaryBtn(
                    onPressed: () {
                      context.read<ProfileBloc>().add(LoadProfile());
                    },
                    label: 'Retry',
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded || state is ProfileUpdating) {
            final profile = state is ProfileLoaded
                ? state.profile
                : (state as ProfileUpdating).profile;

            return EditProfileScreen(profile: profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
