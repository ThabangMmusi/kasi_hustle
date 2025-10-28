import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/styled_text_input.dart';
import 'package:kasi_hustle/features/auth/bloc/auth_bloc.dart';

class EmailForm extends StatelessWidget {
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onCancel;

  const EmailForm({
    super.key,
    required this.emailController,
    required this.formKey,
    required this.isLoading,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledTextInput(
            controller: emailController,
            hintText: 'your.email@example.com',
            prefixIcon: Icon(
              Icons.email_outlined,
              size: IconSizes.med,
              color: const Color(0xFF2E1C13),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          VSpace.lg,
          Row(
            children: [
              Expanded(
                child: PrimaryBtn(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              SendMagicLinkEvent(emailController.text.trim()),
                            );
                          }
                        },
                  label: 'Send Magic Link',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          VSpace.med,
          Center(
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF2E1C13).withValues(alpha: 0.1),
              child: IconButton(
                onPressed: isLoading ? null : onCancel,
                splashRadius: 20,
                icon: Icon(
                  Ionicons.close,
                  size: IconSizes.sm,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
