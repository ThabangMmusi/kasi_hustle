import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/buttons.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/features/profile/domain/models/user_profile.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kasi_hustle/features/profile/presentation/bloc/profile_event.dart';

class EditNamesScreen extends StatefulWidget {
  final UserProfile profile;

  const EditNamesScreen({super.key, required this.profile});

  @override
  State<EditNamesScreen> createState() => _EditNamesScreenState();
}

class _EditNamesScreenState extends State<EditNamesScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false, // Manual handling for custom padding
      appBar: AppBar(
        title: Text(
          'Names',
          style: TextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFFCF7F2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Ionicons.close,
                color: colorScheme.onSurface,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Insets.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledTextInput(
                    controller: _firstNameController,
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    autoFocus: true,
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
              Insets.lg,
            ).copyWith(bottom: bottomPadding + Insets.med + keyboardPadding),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onPressed: () {
                  final updatedProfile = widget.profile.copyWith(
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                  );

                  if (updatedProfile != widget.profile) {
                    context.read<ProfileBloc>().add(
                      UpdateProfile(profile: updatedProfile),
                    );
                  }
                  context.pop();
                },
                label: 'Done',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
