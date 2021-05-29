import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ProgressPainter extends CustomPainter {
  final Color defaultCircleColor;
  final Color percentageCompletedCircleColor;
  final double completedPercentage;
  final double circleWidth;

  ProgressPainter(
      {this.defaultCircleColor,
      this.percentageCompletedCircleColor,
      this.circleWidth,
      this.completedPercentage});

  getPaint(Color color) {
    return Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = circleWidth;
  }

  getShadowPaint(Color color) {
    return Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (3))
      ..style = PaintingStyle.stroke
      ..strokeWidth = circleWidth + 7;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultCirclePaint = getPaint(defaultCircleColor);
    Paint progressCirclePaint = getPaint(percentageCompletedCircleColor);

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) * 1.5;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi * 4 / 5,
        pi * 1.4, false, progressCirclePaint);

    canvas.drawArc(
        Rect.fromCircle(center: center + Offset(1, 1), radius: radius),
        pi * 4 / 5,
        pi * 1.4,
        false,
        getShadowPaint(percentageCompletedCircleColor.withAlpha(50)));

    /*    canvas.drawArc(
        Rect.fromLTRB(
            marginLeft, 5, marginRight, getProportionateScreenHeight(250)),
        pi * 1 / 2,
        pi,
        false,
        progressCirclePaint); */

    double arcAngle = 1.4 * pi * (completedPercentage / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi * 4 / 5,
        arcAngle, false, defaultCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
