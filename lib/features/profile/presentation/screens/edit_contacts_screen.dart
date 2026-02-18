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

class EditContactsScreen extends StatefulWidget {
  final UserProfile profile;

  const EditContactsScreen({super.key, required this.profile});

  @override
  State<EditContactsScreen> createState() => _EditContactsScreenState();
}

class _EditContactsScreenState extends State<EditContactsScreen> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _phoneController = TextEditingController(
      text: widget.profile.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Contacts',
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
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    autoFocus: true,
                  ),
                  VSpace.lg,
                  StyledTextInput(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
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
                    email: _emailController.text.trim().isEmpty
                        ? null
                        : _emailController.text.trim(),
                    phoneNumber: _phoneController.text.trim().isEmpty
                        ? null
                        : _phoneController.text.trim(),
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
