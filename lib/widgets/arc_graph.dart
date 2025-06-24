// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';

class ArcGraph extends StatelessWidget {
  final double percentage;
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final Gradient? gradient;
  final bool animating;

  const ArcGraph({
    super.key,
    required this.percentage,
    this.width = 1,
    this.height = 1,
    this.color = Colors.blue,
    this.strokeWidth = 10, // default strokeWidth
    this.gradient,
    this.animating = false,
  });

  @override
  Widget build(BuildContext context) {
    double size = width < height ? width : height;
    return CustomPaint(
      size: Size(size, size),
      painter:
          _ArcGraphPainter(percentage, color, strokeWidth, gradient, animating),
    );
  }
}

class _ArcGraphPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;
  final bool animating;
  final Gradient? gradient;

  _ArcGraphPainter(this.percentage, this.color, this.strokeWidth, this.gradient,
      this.animating);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
          size.width - strokeWidth, size.height);
      paint.shader = gradient!.createShader(rect);
    }

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth / 2)
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    final startAngle = -pi;
    final sweepAngle = pi * percentage;

    final path = Path()
          ..addArc(Rect.fromLTWH(0, 0, size.width, size.height), startAngle,
              sweepAngle)
          // ..addArc(
          //   Rect.fromCircle(
          //     center: Offset(
          //       size.width / 2 + (size.width / 2 - strokeWidth / 2) * cos(startAngle + sweepAngle),
          //       size.height / 2 + (size.height / 2 - strokeWidth / 2) * sin(startAngle + sweepAngle),
          //     ),
          //     radius: strokeWidth / 2,
          //   ),
          //   0,
          //   2 * pi,
          // )
          ..addArc(
            Rect.fromLTWH(strokeWidth, strokeWidth,
                size.width - strokeWidth * 2, size.height - strokeWidth * 2),
            startAngle + sweepAngle,
            -sweepAngle,
          )
        // ..addArc(
        //   Rect.fromCircle(
        //     center: Offset(
        //       size.width / 2 + (size.width / 2 - strokeWidth / 2) * cos(startAngle),
        //       size.height / 2 + (size.height / 2 - strokeWidth / 2) * sin(startAngle),
        //     ),
        //     radius: strokeWidth / 2,
        //   ),
        //   0,
        //   2 * pi,
        // )
        // ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, sweepAngle, true)
        // ..arcTo(Rect.fromLTWH(0, 0, size.width, size.height), startAngle, sweepAngle, true)
        //
        ;

    // canvas.save();
    // canvas.clipPath(path);
    // canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    // canvas.restore();

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return animating;
  }
}
