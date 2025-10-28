import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class MagicLinkDialog extends StatelessWidget {
  final String email;

  const MagicLinkDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Corners.xl),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Sizes.hit * 2,
            height: Sizes.hit * 2,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EDE3).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: const Color(0xFFF4EDE3),
              size: IconSizes.xl,
            ),
          ),
          VSpace.xl,
          UiText(
            text: 'Check Your Email!',
            style: TextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          VSpace.med,
          UiText(
            text: 'We sent a magic link to',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          VSpace.xs,
          UiText(
            text: email,
            style: TextStyles.bodyMedium.copyWith(
              color: const Color(0xFFF4EDE3),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          VSpace.med,
          UiText(
            text: 'Click the link in your email to sign in.',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          VSpace.xl,
          PrimaryBtn(
            onPressed: () => Navigator.pop(context),
            label: 'Got it!',
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(
                const Color(0xFFF4EDE3),
              ),
              foregroundColor: MaterialStatePropertyAll(Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => MagicLinkDialog(email: email),
    );
  }
}
