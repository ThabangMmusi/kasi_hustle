import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper to create a custom BitmapDescriptor from an IconData.
class MapMarkerHelper {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color iconColor,
    double size = 120, // Logical pixels, will be scaled
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    final double radius = size / 2;

    // Draw Circle Background
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Draw Icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.6, // Icon size relative to marker
        fontFamily: icon.fontFamily,
        color: iconColor,
        package: icon.fontPackage,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }
}
