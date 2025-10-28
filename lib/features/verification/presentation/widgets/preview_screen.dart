import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';
import 'package:kasi_hustle/core/widgets/buttons/primary_btn.dart';
import 'package:kasi_hustle/core/widgets/buttons/secondary_btn.dart';
import 'package:kasi_hustle/features/verification/presentation/widgets/verification_app_bar.dart';

class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;
  final String confirmButtonText;
  final bool isSelfie;

  const PreviewScreen({
    super.key,
    required this.imageFile,
    required this.onRetake,
    required this.onConfirm,
    required this.confirmButtonText,
    required this.isSelfie,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VerificationAppBar(title: 'Preview'),
      body: Column(
        children: [
          Expanded(
            child: isSelfie
                ? Transform.scale(scaleX: -1, child: Image.file(imageFile))
                : Image.file(imageFile),
          ),
          Padding(
            padding: EdgeInsets.all(Insets.xl),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryBtn(onPressed: onRetake, label: 'Retake'),
                ),
                HSpace.lg,
                Expanded(
                  child: PrimaryBtn(
                    onPressed: onConfirm,
                    label: confirmButtonText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
