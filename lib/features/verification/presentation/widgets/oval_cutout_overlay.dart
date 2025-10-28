import 'package:flutter/material.dart';

class OvalCutoutOverlay extends StatelessWidget {
  const OvalCutoutOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OvalCutoutPainter(Theme.of(context).colorScheme),
      child: Container(),
    );
  }
}

class OvalCutoutPainter extends CustomPainter {
  final ColorScheme colorScheme;

  OvalCutoutPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = colorScheme.surface;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2 * 1.2,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(rect),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
