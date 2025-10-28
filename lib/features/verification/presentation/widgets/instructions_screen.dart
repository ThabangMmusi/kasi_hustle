import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/text_btn.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';
import 'package:kasi_hustle/core/routing/app_router.dart';
import 'package:kasi_hustle/core/services/user_profile_service.dart';

class InstructionsScreen extends StatelessWidget {
  final VoidCallback onCompleted;

  const InstructionsScreen({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(Insets.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VSpace.xxl,
            UiText(
              text: 'Verify Your Identity',
              style: TextStyles.headlineMedium,
            ),
            VSpace.med,
            UiText(
              text:
                  'We need to confirm you are who you say you are. This helps keep our community safe.',
              style: TextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            VSpace.xxl,
            _buildInstructionItem(
              context,
              Ionicons.camera_outline,
              '1. Take a clear selfie',
              'Make sure your face is well-lit and centered.',
            ),
            VSpace.xl,
            _buildInstructionItem(
              context,
              Ionicons.card_outline,
              '2. Capture your ID document',
              'Use a valid government-issued ID (ID card, driver license, or passport).',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryBtn(
                onPressed: onCompleted,
                label: 'Get Started',
                icon: Ionicons.arrow_forward_outline,
                iconIsRight: true,
              ),
            ),
            VSpace.med,
            Center(
              child: TextBtn(
                'Maybe Later',
                onPressed: () {
                  final userService = UserProfileService();
                  final userType =
                      userService.currentUser?.userType ?? 'hustler';
                  final destination = userType == 'hustler'
                      ? AppRoutes.home
                      : AppRoutes.businessHome;
                  context.go(destination);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: IconSizes.lg),
        HSpace.lg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiText(
                text: title,
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              VSpace.xs,
              UiText(
                text: subtitle,
                style: TextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
