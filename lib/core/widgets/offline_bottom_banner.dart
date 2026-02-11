import 'package:flutter/material.dart';
import '../theme/styles.dart';

class OfflineBottomBanner extends StatelessWidget {
  const OfflineBottomBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.9),
      padding: EdgeInsets.symmetric(vertical: Insets.xs),
      child: SafeArea(
        top: false,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: IconSizes.sm,
                color: Colors.white,
              ),
              HSpace.xs,
              Text(
                'You are offline',
                style: TextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
