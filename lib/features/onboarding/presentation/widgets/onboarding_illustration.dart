import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/global/design_system/app_color/app_colors.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

/// Which step of the real Field Adjuster workflow a page illustrates.
enum OnboardingArt { assignments, vehicle, scene, evidence, submit }

/// A composed, hand-painted scene for one onboarding page.
///
/// Painted rather than shipped as an asset so every stroke takes its
/// colour from the active scheme — the compositions read correctly in
/// light, dark and a custom accent without five sets of images.
///
/// [progress] drives a gentle entrance: elements settle into place and
/// fade up rather than appearing all at once.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.art,
    required this.progress,
  });

  final OnboardingArt art;

  /// 0 to 1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.12,
        child: CustomPaint(
          painter: _OnboardingPainter(
            art: art,
            colors: colors,
            progress: progress.clamp(0.0, 1.0),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _OnboardingPainter extends CustomPainter {
  _OnboardingPainter({
    required this.art,
    required this.colors,
    required this.progress,
  });

  final OnboardingArt art;
  final AppColors colors;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackdrop(canvas, size);

    // Each scene eases in and drifts up a few pixels as it settles.
    final settle = Curves.easeOutCubic.transform(progress);
    canvas.save();
    canvas.translate(0, (1 - settle) * size.height * 0.05);

    switch (art) {
      case OnboardingArt.assignments:
        _paintAssignments(canvas, size, settle);
      case OnboardingArt.vehicle:
        _paintVehicle(canvas, size, settle);
      case OnboardingArt.scene:
        _paintScene(canvas, size, settle);
      case OnboardingArt.evidence:
        _paintEvidence(canvas, size, settle);
      case OnboardingArt.submit:
        _paintSubmit(canvas, size, settle);
    }
    canvas.restore();
  }

  // --- shared -------------------------------------------------------------

  /// Soft concentric halo behind every scene, so the compositions share
  /// a family resemblance.
  void _paintBackdrop(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.48);
    final radius = size.shortestSide * 0.46;
    final bloom = Curves.easeOut.transform(progress);

    canvas.drawCircle(
      centre,
      radius * (0.92 + 0.08 * bloom),
      Paint()..color = colors.primaryColor.changeOpacity(0.06 * bloom),
    );
    canvas.drawCircle(
      centre,
      radius * (0.68 + 0.06 * bloom),
      Paint()..color = colors.primaryColor.changeOpacity(0.07 * bloom),
    );
    canvas.drawCircle(
      centre,
      radius * (0.92 + 0.08 * bloom),
      Paint()
        ..color = colors.primaryColor.changeOpacity(0.16 * bloom)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.004,
    );
  }

  Paint get _surface => Paint()..color = colors.cardColor;

  Paint _outline(double width) => Paint()
    ..color = colors.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = width;

  Paint _accent({double opacity = 1, PaintingStyle style = PaintingStyle.fill})
      => Paint()
    ..color = colors.primaryColor.changeOpacity(opacity)
    ..style = style;

  void _card(Canvas canvas, Rect rect, double radius, {double elevation = 1}) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(
      rrect.shift(Offset(0, elevation * 3)),
      Paint()
        ..color = colors.shadowColor.changeOpacity(0.07)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, elevation * 6),
    );
    canvas.drawRRect(rrect, _surface);
    canvas.drawRRect(rrect, _outline(1.2));
  }

  /// A stand-in text line; length is a fraction of the card width.
  void _line(
    Canvas canvas,
    Offset start,
    double width,
    double thickness, {
    double opacity = 0.22,
    Color? color,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(start.dx, start.dy, width, thickness),
        Radius.circular(thickness / 2),
      ),
      Paint()
        ..color = (color ?? colors.textSecondaryColor).changeOpacity(opacity),
    );
  }

  void _check(Canvas canvas, Offset centre, double radius, {Color? fill}) {
    canvas.drawCircle(centre, radius, Paint()..color = fill ?? colors.successColor);
    final path = Path()
      ..moveTo(centre.dx - radius * 0.42, centre.dy + radius * 0.02)
      ..lineTo(centre.dx - radius * 0.10, centre.dy + radius * 0.34)
      ..lineTo(centre.dx + radius * 0.44, centre.dy - radius * 0.30);
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.onStatusColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.22
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // --- 1. assignments offered and accepted --------------------------------

  void _paintAssignments(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // Two cards behind, fanned out, and the active one in front.
    for (var i = 2; i >= 1; i--) {
      final inset = i * w * 0.055;
      final lift = i * h * 0.05 * (0.4 + 0.6 * t);
      _card(
        canvas,
        Rect.fromLTWH(
          w * 0.20 + inset * 0.5,
          h * 0.24 - lift,
          w * 0.60 - inset,
          h * 0.14,
        ),
        w * 0.035,
        elevation: 0.5,
      );
    }

    final front = Rect.fromLTWH(w * 0.16, h * 0.38, w * 0.68, h * 0.30);
    _card(canvas, front, w * 0.045, elevation: 1.6);

    // Priority pill.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(front.left + w * 0.06, front.top + h * 0.05, w * 0.14,
            h * 0.045),
        Radius.circular(h * 0.03),
      ),
      _accent(opacity: 0.18),
    );
    _line(
      canvas,
      Offset(front.left + w * 0.06, front.top + h * 0.13),
      w * 0.40,
      h * 0.022,
      opacity: 0.30,
    );
    _line(
      canvas,
      Offset(front.left + w * 0.06, front.top + h * 0.19),
      w * 0.28,
      h * 0.018,
      opacity: 0.18,
    );

    // The accept mark lands last.
    final markProgress = Curves.easeOutBack.transform(
      ((t - 0.45) / 0.55).clamp(0.0, 1.0),
    );
    if (markProgress > 0) {
      _check(
        canvas,
        Offset(front.right - w * 0.10, front.bottom - h * 0.08),
        w * 0.075 * markProgress,
      );
    }
  }

  // --- 2. plate to vehicle, customer and policy ---------------------------

  void _paintVehicle(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    final plate = Rect.fromLTWH(w * 0.20, h * 0.30, w * 0.60, h * 0.20);
    _card(canvas, plate, w * 0.035, elevation: 1.4);

    // Plate characters.
    for (var i = 0; i < 6; i++) {
      final cw = w * 0.058;
      _line(
        canvas,
        Offset(plate.left + w * 0.07 + i * (cw + w * 0.014),
            plate.top + h * 0.065),
        cw,
        h * 0.07,
        opacity: 0.26,
        color: colors.textPrimaryColor,
      );
    }

    // Scan beam sweeping the plate.
    final sweep = Curves.easeInOut.transform(t);
    final beamY = plate.top + plate.height * sweep;
    canvas.drawRect(
      Rect.fromLTWH(plate.left, beamY - h * 0.006, plate.width, h * 0.012),
      Paint()
        ..shader = LinearGradient(
          colors: [
            colors.primaryColor.changeOpacity(0),
            colors.primaryColor.changeOpacity(0.85),
            colors.primaryColor.changeOpacity(0),
          ],
        ).createShader(
          Rect.fromLTWH(plate.left, beamY - h * 0.01, plate.width, h * 0.02),
        ),
    );

    // Corner brackets framing the scan.
    final bracket = w * 0.06;
    final framePaint = _accent(opacity: 0.9, style: PaintingStyle.stroke)
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round;
    final frame = plate.inflate(w * 0.035);
    for (final corner in [
      (frame.topLeft, 1.0, 1.0),
      (frame.topRight, -1.0, 1.0),
      (frame.bottomLeft, 1.0, -1.0),
      (frame.bottomRight, -1.0, -1.0),
    ]) {
      final (point, sx, sy) = corner;
      canvas.drawLine(
        point,
        point + Offset(bracket * sx, 0),
        framePaint,
      );
      canvas.drawLine(point, point + Offset(0, bracket * sy), framePaint);
    }

    // Resolved records dropping in below: vehicle, customer, policy.
    for (var i = 0; i < 3; i++) {
      final appear = ((t - 0.35 - i * 0.14) / 0.3).clamp(0.0, 1.0);
      if (appear <= 0) continue;
      final row = Rect.fromLTWH(
        w * 0.24,
        h * 0.60 + i * h * 0.105,
        w * 0.52 * appear,
        h * 0.075,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(row, Radius.circular(h * 0.037)),
        Paint()..color = colors.iconBackgroundColor,
      );
      canvas.drawCircle(
        Offset(row.left + h * 0.037, row.center.dy),
        h * 0.020,
        _accent(opacity: 0.55),
      );
      if (appear > 0.6) {
        _line(
          canvas,
          Offset(row.left + h * 0.075, row.center.dy - h * 0.008),
          row.width * 0.5,
          h * 0.016,
          opacity: 0.25,
        );
      }
    }
  }

  // --- 3. accident details plus a real GPS fix ----------------------------

  void _paintScene(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final centre = Offset(w * 0.5, h * 0.44);

    // Radar rings pulsing out from the fix.
    for (var i = 0; i < 3; i++) {
      final phase = ((t * 1.4) - i * 0.22).clamp(0.0, 1.0);
      if (phase <= 0) continue;
      canvas.drawCircle(
        centre,
        w * (0.10 + 0.20 * phase),
        Paint()
          ..color = colors.primaryColor.changeOpacity(0.32 * (1 - phase))
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.006,
      );
    }

    // Pin.
    final pinScale = Curves.easeOutBack.transform(
      (t / 0.6).clamp(0.0, 1.0),
    );
    final pinHeight = h * 0.22 * pinScale;
    final pinWidth = pinHeight * 0.72;
    final pinTop = centre.dy - pinHeight * 0.62;
    final pin = Path()
      ..moveTo(centre.dx, centre.dy + pinHeight * 0.38)
      ..cubicTo(
        centre.dx - pinWidth * 0.62, centre.dy - pinHeight * 0.10,
        centre.dx - pinWidth * 0.58, pinTop,
        centre.dx, pinTop,
      )
      ..cubicTo(
        centre.dx + pinWidth * 0.58, pinTop,
        centre.dx + pinWidth * 0.62, centre.dy - pinHeight * 0.10,
        centre.dx, centre.dy + pinHeight * 0.38,
      )
      ..close();
    canvas.drawPath(pin, _accent());
    canvas.drawCircle(
      Offset(centre.dx, centre.dy - pinHeight * 0.16),
      pinWidth * 0.20,
      Paint()..color = colors.cardColor,
    );

    // Accident detail card underneath.
    final card = Rect.fromLTWH(w * 0.16, h * 0.66, w * 0.68, h * 0.24);
    _card(canvas, card, w * 0.045, elevation: 1.2);
    _line(canvas, Offset(card.left + w * 0.06, card.top + h * 0.05),
        w * 0.34, h * 0.022, opacity: 0.30);
    _line(canvas, Offset(card.left + w * 0.06, card.top + h * 0.11),
        w * 0.50, h * 0.016, opacity: 0.16);
    _line(canvas, Offset(card.left + w * 0.06, card.top + h * 0.16),
        w * 0.42, h * 0.016, opacity: 0.16);
  }

  // --- 4. photos, documents and the customer signature --------------------

  void _paintEvidence(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    // Fanned photo stack.
    final angles = [-0.20, -0.02, 0.17];
    for (var i = 0; i < angles.length; i++) {
      final appear = ((t - i * 0.12) / 0.5).clamp(0.0, 1.0);
      if (appear <= 0) continue;
      canvas.save();
      canvas.translate(w * 0.5, h * 0.40);
      canvas.rotate(angles[i] * appear);
      final photo = Rect.fromCenter(
        center: Offset(0, 0),
        width: w * 0.46,
        height: h * 0.34,
      );
      _card(canvas, photo, w * 0.03, elevation: 1.2);
      // A simple vehicle silhouette inside the top photo.
      if (i == angles.length - 1) {
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(photo.left + w * 0.06, photo.center.dy - h * 0.015,
              photo.width - w * 0.12, h * 0.062),
          Radius.circular(h * 0.022),
        );
        canvas.drawRRect(body, _accent(opacity: 0.30));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(photo.left + w * 0.12,
                photo.center.dy - h * 0.052, photo.width - w * 0.24,
                h * 0.042),
            Radius.circular(h * 0.016),
          ),
          _accent(opacity: 0.18),
        );
        for (final dx in [-0.10, 0.10]) {
          canvas.drawCircle(
            Offset(photo.center.dx + w * dx, photo.center.dy + h * 0.048),
            h * 0.017,
            Paint()..color = colors.textSecondaryColor.changeOpacity(0.45),
          );
        }
      }
      canvas.restore();
    }

    // Signature line being drawn.
    final signCard = Rect.fromLTWH(w * 0.18, h * 0.68, w * 0.64, h * 0.22);
    _card(canvas, signCard, w * 0.04, elevation: 1);
    final signature = Path();
    final amplitude = h * 0.045;
    final baseline = signCard.center.dy + h * 0.015;
    signature.moveTo(signCard.left + w * 0.08, baseline);
    final span = signCard.width - w * 0.16;
    final drawn = Curves.easeInOut.transform(
      ((t - 0.3) / 0.7).clamp(0.0, 1.0),
    );
    for (var i = 1; i <= 40; i++) {
      final p = i / 40;
      if (p > drawn) break;
      final x = signCard.left + w * 0.08 + span * p;
      final y = baseline -
          math.sin(p * math.pi * 2.6) * amplitude * (1 - p * 0.35);
      signature.lineTo(x, y);
    }
    canvas.drawPath(
      signature,
      Paint()
        ..color = colors.textPrimaryColor.changeOpacity(0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.009
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    _line(
      canvas,
      Offset(signCard.left + w * 0.08, signCard.bottom - h * 0.045),
      span,
      h * 0.006,
      opacity: 0.20,
    );
  }

  // --- 5. review each section, then submit --------------------------------

  void _paintSubmit(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;

    final sheet = Rect.fromLTWH(w * 0.22, h * 0.16, w * 0.56, h * 0.56);
    _card(canvas, sheet, w * 0.045, elevation: 1.8);

    // Review rows ticking off one by one.
    for (var i = 0; i < 4; i++) {
      final y = sheet.top + h * 0.09 + i * h * 0.115;
      final done = ((t - 0.15 - i * 0.16) / 0.25).clamp(0.0, 1.0);
      _line(
        canvas,
        Offset(sheet.left + w * 0.16, y),
        sheet.width * 0.50,
        h * 0.020,
        opacity: 0.16 + 0.14 * done,
      );
      if (done > 0) {
        _check(
          canvas,
          Offset(sheet.left + w * 0.09, y + h * 0.010),
          w * 0.035 * Curves.easeOutBack.transform(done),
        );
      }
    }

    // Submit action lifting off the sheet.
    final lift = Curves.easeOutCubic.transform(
      ((t - 0.55) / 0.45).clamp(0.0, 1.0),
    );
    if (lift > 0) {
      final button = Rect.fromCenter(
        center: Offset(w * 0.5, sheet.bottom + h * 0.06 - h * 0.03 * lift),
        width: w * 0.44,
        height: h * 0.10,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(button, Radius.circular(button.height / 2)),
        Paint()..color = colors.primaryColor.changeOpacity(lift),
      );
      // Paper-plane glyph.
      final c = button.center;
      final s = button.height * 0.30;
      final plane = Path()
        ..moveTo(c.dx - s, c.dy)
        ..lineTo(c.dx + s, c.dy - s * 0.72)
        ..lineTo(c.dx + s * 0.18, c.dy)
        ..lineTo(c.dx + s, c.dy + s * 0.72)
        ..close();
      canvas.drawPath(
        plane,
        Paint()..color = colors.onPrimaryColor.changeOpacity(lift),
      );
    }
  }

  @override
  bool shouldRepaint(_OnboardingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.art != art ||
        oldDelegate.colors != colors;
  }
}
