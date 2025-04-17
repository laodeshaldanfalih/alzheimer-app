import 'dart:math';

import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundGradient = Paint()
      ..shader = RadialGradient(
        colors: [Colors.blue.shade100, Colors.white],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, backgroundGradient);

    final outline = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius, outline);

    // Gambar angka 1–12
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * pi / 180;
      final offset = Offset(
        center.dx + (radius - 20) * cos(angle - pi / 2),
        center.dy + (radius - 20) * sin(angle - pi / 2),
      );

      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      canvas.save();
      canvas.translate(offset.dx - textPainter.width / 2,
                       offset.dy - textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Panjang jarum
    final hourLength = radius * 0.5;
    final minuteLength = radius * 0.7;
    final secondLength = radius * 0.9;

    // Hitung sudut
    final hourAngle = (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180;
    final minuteAngle = dateTime.minute * 6 * pi / 180;
    final secondAngle = dateTime.second * 6 * pi / 180;

    // Jarum jam
    final hourHand = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    final minuteHand = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final secondHand = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    // Gambar jarum jam
    canvas.drawLine(
      center,
      Offset(center.dx + hourLength * cos(hourAngle - pi / 2),
             center.dy + hourLength * sin(hourAngle - pi / 2)),
      hourHand,
    );

    canvas.drawLine(
      center,
      Offset(center.dx + minuteLength * cos(minuteAngle - pi / 2),
             center.dy + minuteLength * sin(minuteAngle - pi / 2)),
      minuteHand,
    );

    canvas.drawLine(
      center,
      Offset(center.dx + secondLength * cos(secondAngle - pi / 2),
             center.dy + secondLength * sin(secondAngle - pi / 2)),
      secondHand,
    );

    // Titik tengah
    final centerDot = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
