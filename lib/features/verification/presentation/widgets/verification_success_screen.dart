import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/ui_text.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.sparkles, color: colorScheme.primary, size: 100),
            VSpace.lg,
            UiText(
              text: 'Verification Successful!',
              style: TextStyles.headlineSmall,
            ),
            VSpace.sm,
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
          ],
        ),
      ),
    );
  }
}
