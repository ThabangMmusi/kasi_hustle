import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/features/auth/bloc/auth_bloc.dart';

class LoginOptions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onEmailPressed;

  const LoginOptions({
    super.key,
    required this.isLoading,
    required this.onEmailPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryBtn(
                onPressed: isLoading
                    ? null
                    : () =>
                          context.read<AuthBloc>().add(SignInWithGoogleEvent()),
                label: 'Continue with Google',
                icon: Ionicons.logo_google,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        VSpace.lg,
        Row(
          children: [
            Expanded(
              child: SecondaryBtn(
                onPressed: isLoading ? null : onEmailPressed,
                label: 'Continue with Email',
                icon: Icons.email_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
