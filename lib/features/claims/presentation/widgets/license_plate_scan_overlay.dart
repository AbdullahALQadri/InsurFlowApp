import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';

/// Wide plate window (not a square QR reticle).
class LicensePlateFrameGeometry {
  LicensePlateFrameGeometry._();

  static const aspectRatio = 3.05;
  static const widthFactor = 0.88;
  static const verticalCenterFactor = 0.38;
  static const cornerRadius = 14.0;

  static Rect of(Size size) {
    final width = size.width * widthFactor;
    final height = width / aspectRatio;
    final left = (size.width - width) / 2;
    final top = size.height * verticalCenterFactor - height / 2;
    return Rect.fromLTWH(left, top, width, height);
  }

  static RRect rrect(Size size) {
    return RRect.fromRectAndRadius(
      of(size),
      const Radius.circular(cornerRadius),
    );
  }
}

class LicensePlateScanOverlay extends StatelessWidget {
  const LicensePlateScanOverlay({
    super.key,
    required this.scanProgress,
    required this.flashOn,
    required this.onBack,
    required this.onToggleFlash,
    required this.onCapture,
    this.flashEnabled = true,
    this.cameraMessage,
  });

  final double scanProgress;
  final bool flashOn;
  final bool flashEnabled;
  final VoidCallback onBack;
  final VoidCallback onToggleFlash;
  final VoidCallback onCapture;
  final String? cameraMessage;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = LicensePlateFrameGeometry.of(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _PlateScrimPainter(frame: frame)),
            CustomPaint(
              painter: _PlateScanSweepPainter(
                frame: frame,
                progress: scanProgress,
              ),
            ),
            CustomPaint(painter: _PlateFramePainter(frame: frame)),
            Positioned(
              left: frame.left + context.width(12),
              right: size.width - frame.right + context.width(12),
              top: frame.top + (frame.height / 2) - context.height(18),
              child: _FrameHint(label: strings.positionPlateInFrame),
            ),
            _TopChrome(
              title: strings.scanLicensePlate,
              flashOn: flashOn,
              flashEnabled: flashEnabled,
              onBack: onBack,
              onToggleFlash: onToggleFlash,
            ),
            _BottomChrome(
              instruction: cameraMessage ?? strings.keepPlateVisible,
              onCapture: onCapture,
            ),
          ],
        );
      },
    );
  }
}

class _FrameHint extends StatelessWidget {
  const _FrameHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.navy.changeOpacity(0.90),
        borderRadius: context.circularRadius(8),
        border: Border.all(color: AppSplashColors.cyan.changeOpacity(0.35)),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 8, horizontal: 12),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.font14Regular?.copyWith(
            color: AppSplashColors.textPrimary,
            fontWeight: FontWeightHelper.medium,
            height: 1.3,
            fontSize: context.width(13),
            shadows: const [
              Shadow(color: AppPalette.immersiveScrim, blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.title,
    required this.flashOn,
    required this.flashEnabled,
    required this.onBack,
    required this.onToggleFlash,
  });

  final String title;
  final bool flashOn;
  final bool flashEnabled;
  final VoidCallback onBack;
  final VoidCallback onToggleFlash;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.immersiveSurface.changeOpacity(0.80),
            AppPalette.immersiveSurface.changeOpacity(0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.spaceSymmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              _ChromeIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: strings.cancel,
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.font18Bold?.copyWith(
                    color: AppSplashColors.textPrimary,
                    fontWeight: FontWeightHelper.semiBold,
                    shadows: const [
                      Shadow(color: AppPalette.immersiveScrim, blurRadius: 8),
                    ],
                  ),
                ),
              ),
              _ChromeIconButton(
                icon: flashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                tooltip: strings.toggleFlash,
                onPressed: flashEnabled ? onToggleFlash : null,
                active: flashOn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomChrome extends StatelessWidget {
  const _BottomChrome({required this.instruction, required this.onCapture});

  final String instruction;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppPalette.immersiveSurface.changeOpacity(0.95),
              AppPalette.immersiveSurface.changeOpacity(0),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: context.spaceSymmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppPalette.immersivePanel.changeOpacity(0.95),
                    borderRadius: context.circularRadius(16),
                    border: Border.all(
                      color: AppSplashColors.cyan.changeOpacity(0.22),
                    ),
                  ),
                  child: Padding(
                    padding: context.spaceSymmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    child: Text(
                      instruction,
                      textAlign: TextAlign.center,
                      style: context.font16Regular?.copyWith(
                        color: AppSplashColors.textPrimary,
                        fontWeight: FontWeightHelper.medium,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                context.addVerticalSpace(18),
                Semantics(
                  key: const Key('license-plate-capture'),
                  button: true,
                  label: strings.capturePlate,
                  child: _CaptureButton(onPressed: onCapture),
                ),
                context.addVerticalSpace(8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChromeIconButton extends StatelessWidget {
  const _ChromeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? AppSplashColors.cyan.changeOpacity(0.28)
            : AppPalette.immersiveScrim.changeOpacity(0.4),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: context.width(44),
            height: context.width(44),
            child: Icon(
              icon,
              color: enabled
                  ? AppSplashColors.textPrimary
                  : AppSplashColors.textSubtle,
              size: context.width(22),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onPressed});

  final VoidCallback onPressed;

  static const _ringWidth = 3.0;

  @override
  Widget build(BuildContext context) {
    final outer = context.width(78);
    final inner = context.width(62);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: outer,
          height: outer,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.immersiveInk,
                width: _ringWidth,
              ),
            ),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppSplashColors.glow, AppSplashColors.cyanDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppSplashColors.cyan.changeOpacity(0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: SizedBox(width: inner, height: inner),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlateScrimPainter extends CustomPainter {
  const _PlateScrimPainter({required this.frame});

  final Rect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final cutout = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(LicensePlateFrameGeometry.cornerRadius),
    );
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(cutout)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      path,
      Paint()..color = AppPalette.immersiveSurface.changeOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _PlateScrimPainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

class _PlateFramePainter extends CustomPainter {
  const _PlateFramePainter({required this.frame});

  final Rect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(LicensePlateFrameGeometry.cornerRadius),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppSplashColors.cyan.changeOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final corner = Paint()
      ..color = AppSplashColors.glow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final length = frame.shortestSide * 0.28;
    void drawCorner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * length, 0), corner);
      canvas.drawLine(origin, origin.translate(0, dy * length), corner);
    }

    drawCorner(frame.topLeft, 1, 1);
    drawCorner(frame.topRight, -1, 1);
    drawCorner(frame.bottomLeft, 1, -1);
    drawCorner(frame.bottomRight, -1, -1);

    final midPaint = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.7)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final midY = frame.center.dy;
    canvas.drawLine(
      Offset(frame.left, midY),
      Offset(frame.left + 10, midY),
      midPaint,
    );
    canvas.drawLine(
      Offset(frame.right, midY),
      Offset(frame.right - 10, midY),
      midPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlateFramePainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

class _PlateScanSweepPainter extends CustomPainter {
  const _PlateScanSweepPainter({required this.frame, required this.progress});

  final Rect frame;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      frame.deflate(2),
      const Radius.circular(LicensePlateFrameGeometry.cornerRadius - 2),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    final y = frame.top + frame.height * progress;
    for (var i = 0; i < 3; i++) {
      final offset = i * 7.0;
      final lineY = y - offset;
      if (lineY < frame.top || lineY > frame.bottom) continue;
      final opacity = 0.7 - (i * 0.22);
      canvas.drawLine(
        Offset(frame.left + 8, lineY),
        Offset(frame.right - 8, lineY),
        Paint()
          ..color = AppSplashColors.cyan.changeOpacity(opacity)
          ..strokeWidth = i == 0 ? 1.6 : 1.1
          ..strokeCap = StrokeCap.round,
      );
    }

    final band = Rect.fromLTWH(frame.left, y - 10, frame.width, 20);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppSplashColors.cyan.changeOpacity(0),
            AppSplashColors.cyan.changeOpacity(0.12),
            AppSplashColors.cyan.changeOpacity(0),
          ],
        ).createShader(band),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlateScanSweepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.frame != frame;
  }
}
