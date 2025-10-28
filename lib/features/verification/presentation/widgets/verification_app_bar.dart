import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/widgets/buttons/icon_btn.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:kasi_hustle/features/verification/presentation/bloc/verification_event.dart';

class VerificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const VerificationAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      title: UiText(text: title),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconBtn(
        Ionicons.arrow_back,
        onPressed: () =>
            context.read<VerificationBloc>().add(GoToPreviousStep()),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
