import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

class RectangleCutoutOverlay extends StatelessWidget {
  const RectangleCutoutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RectangleCutoutPainter(Theme.of(context).colorScheme),
      child: Container(),
    );
  }
}

class RectangleCutoutPainter extends CustomPainter {
  final ColorScheme colorScheme;

  RectangleCutoutPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.surface;
    final center = Offset(size.width / 2, size.height / 2);
    final rectHeight = size.height * 0.7;
    final rectWidth = rectHeight * 0.63; // Aspect ratio of a credit card
    final rect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(rect, Corners.smRadius)),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Corners.smRadius),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
