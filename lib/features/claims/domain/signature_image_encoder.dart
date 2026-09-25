import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Turns the strokes drawn on the signature pad into a real PNG file.
///
/// `POST /claims/{id}/signature` takes a binary image, so the captured
/// path has to be rendered rather than described. The strokes are the
/// customer's actual input — nothing is drawn that they did not.
///
/// The signature is rendered on an opaque white background so it stays
/// legible wherever the claims officer views it, independent of the
/// app theme the adjuster happened to be using.
class SignatureImageEncoder {
  const SignatureImageEncoder();

  static const Color inkColor = Color(0xFF111827);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  /// Renders [strokes] laid out for [size] and writes a PNG to a
  /// temporary file, returning its path. Returns null when there is
  /// nothing to draw or the file could not be written.
  Future<String?> encodeToFile({
    required List<List<Offset>> strokes,
    required Size size,
    required String claimId,
    double pixelRatio = 3,
  }) async {
    if (size.isEmpty) return null;
    final hasInk = strokes.any((stroke) => stroke.isNotEmpty);
    if (!hasInk) return null;

    try {
      final bytes = await _renderPng(
        strokes: strokes,
        size: size,
        pixelRatio: pixelRatio,
      );
      if (bytes == null) return null;

      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/signature_${claimId}_'
        '${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } on Exception catch (error) {
      debugPrint('[signature] encode failed: $error');
      return null;
    }
  }

  Future<Uint8List?> _renderPng({
    required List<List<Offset>> strokes,
    required Size size,
    required double pixelRatio,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(pixelRatio);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    final ink = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      // Matches the on-screen pad so the saved image looks like what
      // the customer signed.
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.2, ink);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, ink);
    }

    final image = await recorder.endRecording().toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
