import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class LoginBottomSheet extends StatelessWidget {
  final bool showEmailField;
  final Widget child;

  const LoginBottomSheet({
    super.key,
    required this.showEmailField,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EDE3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Corners.xxl),
          topRight: Radius.circular(Corners.xxl),
        ),
        boxShadow: Shadows.medium,
      ),
      child: Padding(
        padding: EdgeInsets.all(Insets.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDragIndicator(),
            VSpace.xl,
            _buildTitle(),
            VSpace.xs,
            _buildSubtitle(),
            VSpace.xxl,
            child,
            VSpace.xl,
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Center(
      child: Container(
        width: Sizes.hit,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Corners.xs),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return UiText(
      text: showEmailField ? 'Enter your email' : 'Get Started',
      style: TextStyles.headlineSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubtitle() {
    return UiText(
      text: showEmailField
          ? 'We will send a magic link to this email.'
          : 'Join the hustle. Find jobs or post work.',
      style: TextStyles.bodyLarge.copyWith(
        color: Colors.black.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildTermsText() {
    return UiText(
      text: 'By continuing, you agree to our Terms & Privacy Policy',
      style: TextStyles.caption.copyWith(
        color: Colors.black.withValues(alpha: 0.5),
      ),
      textAlign: TextAlign.center,
    );
  }
}
