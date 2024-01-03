import 'dart:math' as math;
import 'dart:core';
import 'package:flutter/material.dart';

import '/data/models.dart';

class RectangleTextPainter extends CustomPainter {
  ValueNotifier<bool> renderText;
  ValueNotifier<bool> translationLoaded;
  List<FlexTextDetection>? textDetections;
  SupportedLanguage? languageFrom;
  SupportedLanguage? languageTo;
  final borderPaint = Paint()
    ..color = const Color.fromARGB(199, 41, 41, 129)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final transparentFill = Paint()
    ..color = const Color.fromARGB(100, 255, 255, 255)
    ..style = PaintingStyle.fill;
  final opaqueFill = Paint()
    ..color = const Color.fromARGB(200, 255, 255, 255)
    ..style = PaintingStyle.fill;
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16.0);

  RectangleTextPainter({
    required this.textDetections,
    required this.renderText,
    required this.translationLoaded,
    required this.languageFrom,
    required this.languageTo,
  }) : super(repaint: translationLoaded);

  TextPainter getTextPainterFitInRect(String text, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
    double fontSize = 100.0;
    textPainter.text =
        TextSpan(text: text, style: textStyle.copyWith(fontSize: fontSize));
    textPainter.layout();
    while (textPainter.width > rect.width || textPainter.height > rect.height) {
      fontSize -= 1.0;
      textPainter.text =
          TextSpan(text: text, style: textStyle.copyWith(fontSize: fontSize));
      textPainter.layout();
    }
    return textPainter;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (textDetections == null || textDetections!.isEmpty) return;
    for (var textDetection in textDetections!) {
      // Calculate info and draw rect
      final polygon = textDetection.getGeometry()!.polygon!;

      final centerX =
          size.width * (polygon.map((p) => p.x!).reduce((a, b) => a + b) / 4);
      final centerY =
          size.height * (polygon.map((p) => p.y!).reduce((a, b) => a + b) / 4);
      double rectHeight = math.sqrt(
          math.pow((polygon[3].x! - polygon[0].x!) * size.width, 2) +
              math.pow((polygon[3].y! - polygon[0].y!) * size.height, 2));
      double rectWidth = math.sqrt(
          math.pow((polygon[1].x! - polygon[0].x!) * size.width, 2) +
              math.pow((polygon[1].y! - polygon[0].y!) * size.height, 2));

      final rect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: rectWidth,
        height: rectHeight,
      );

      final vector = math.Point(
        size.width * (polygon[1].x! + polygon[2].x!) / 2 - centerX,
        size.height * (polygon[1].y! + polygon[2].y!) / 2 - centerY,
      );
      double angleInRadians = math.atan2(vector.y, vector.x);

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(angleInRadians);
      canvas.translate(-centerX, -centerY);

      final rectPaint = (renderText.value && translationLoaded.value)
          ? opaqueFill
          : transparentFill;
      canvas.drawRect(rect, rectPaint);
      if (!renderText.value) canvas.drawRect(rect, borderPaint);

      // Draw text
      if (renderText.value && translationLoaded.value) {
        final textPainter =
            getTextPainterFitInRect(textDetection.translatedText, rect);
        final textOffset = Offset(
          centerX - textPainter.width / 2,
          centerY - textPainter.height / 2,
        );
        textPainter.paint(canvas, textOffset);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is RectangleTextPainter) {
      // I don't know why this works
      return (oldDelegate.languageFrom == languageFrom) ||
          (oldDelegate.languageTo == languageTo);
    }
    return false;
  }
}
