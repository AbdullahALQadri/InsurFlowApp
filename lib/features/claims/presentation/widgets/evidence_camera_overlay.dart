import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/domain/vehicle_evidence.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';

class EvidenceFrameGeometry {
  EvidenceFrameGeometry._();

  static const cornerRadius = 18.0;
  static const cornerLengthFactor = 0.16;

  static Rect of(Size size, EvidenceCategory category) {
    final widthFactor = switch (category) {
      EvidenceCategory.licensePlate => 0.86,
      EvidenceCategory.damageCloseUp => 0.72,
      EvidenceCategory.accidentScene => 0.88,
      _ => 0.80,
    };
    final heightFactor = switch (category) {
      EvidenceCategory.licensePlate => 0.18,
      EvidenceCategory.damageCloseUp => 0.32,
      EvidenceCategory.accidentScene => 0.40,
      _ => 0.36,
    };
    final centerY = switch (category) {
      EvidenceCategory.licensePlate => 0.40,
      _ => 0.42,
    };
    final width = size.width * widthFactor;
    final height = size.height * heightFactor;
    return Rect.fromLTWH(
      (size.width - width) / 2,
      size.height * centerY - height / 2,
      width,
      height,
    );
  }
}

class EvidenceCameraOverlay extends StatelessWidget {
  const EvidenceCameraOverlay({
    super.key,
    required this.category,
    required this.flashOn,
    required this.onBack,
    required this.onToggleFlash,
    required this.onCapture,
    required this.onGallery,
    this.flashEnabled = true,
    this.cameraMessage,
  });

  final EvidenceCategory category;
  final bool flashOn;
  final bool flashEnabled;
  final VoidCallback onBack;
  final VoidCallback onToggleFlash;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final String? cameraMessage;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = EvidenceFrameGeometry.of(size, category);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _EvidenceGuidePainter(frame: frame, category: category),
            ),
            _TopChrome(
              title: strings.evidenceCategoryLabel(category),
              subtitle: strings.evidenceCameraPrompt(category),
              onBack: onBack,
            ),
            _BottomChrome(
              instruction:
                  cameraMessage ?? strings.evidenceCameraInstruction(category),
              flashOn: flashOn,
              flashEnabled: flashEnabled,
              onCapture: onCapture,
              onGallery: onGallery,
              onToggleFlash: onToggleFlash,
            ),
          ],
        );
      },
    );
  }
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.immersiveSurface.changeOpacity(0.70),
            AppPalette.immersiveSurface.changeOpacity(0),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: context.spaceSymmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                          Shadow(
                            color: AppPalette.immersiveScrim,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: context.width(44)),
                ],
              ),
              context.addVerticalSpace(4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: context.font14Regular?.copyWith(
                  color: AppSplashColors.textMuted,
                  fontWeight: FontWeightHelper.medium,
                  height: 1.3,
                  shadows: const [
                    Shadow(color: AppPalette.immersiveScrim, blurRadius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomChrome extends StatelessWidget {
  const _BottomChrome({
    required this.instruction,
    required this.flashOn,
    required this.flashEnabled,
    required this.onCapture,
    required this.onGallery,
    required this.onToggleFlash,
  });

  final String instruction;
  final bool flashOn;
  final bool flashEnabled;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onToggleFlash;

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
                    color: AppPalette.immersivePanel,
                    borderRadius: context.circularRadius(14),
                    border: Border.all(
                      color: AppSplashColors.cyan.changeOpacity(0.22),
                    ),
                  ),
                  child: Padding(
                    padding: context.spaceSymmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Text(
                      instruction,
                      textAlign: TextAlign.center,
                      style: context.font14Regular?.copyWith(
                        color: AppSplashColors.textPrimary,
                        fontWeight: FontWeightHelper.medium,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                context.addVerticalSpace(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ChromeIconButton(
                      key: const Key('evidence-camera-gallery'),
                      icon: Icons.photo_library_outlined,
                      tooltip: strings.gallery,
                      onPressed: onGallery,
                    ),
                    Semantics(
                      key: const Key('evidence-camera-capture'),
                      button: true,
                      label: strings.captureEvidence,
                      child: _CaptureButton(onPressed: onCapture),
                    ),
                    _ChromeIconButton(
                      key: const Key('evidence-camera-flash'),
                      icon: flashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      tooltip: strings.toggleFlash,
                      onPressed: flashEnabled ? onToggleFlash : null,
                      active: flashOn,
                    ),
                  ],
                ),
                context.addVerticalSpace(6),
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
    super.key,
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
            width: context.width(48),
            height: context.width(48),
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
              boxShadow: [
                BoxShadow(
                  color: AppSplashColors.cyan.changeOpacity(0.22),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.immersiveInk,
                  boxShadow: [
                    BoxShadow(
                      color: AppSplashColors.glow.changeOpacity(0.28),
                      blurRadius: 10,
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

class _EvidenceGuidePainter extends CustomPainter {
  const _EvidenceGuidePainter({required this.frame, required this.category});

  final Rect frame;
  final EvidenceCategory category;

  @override
  void paint(Canvas canvas, Size size) {
    _thirds(canvas);
    _corners(canvas);
    _silhouette(canvas);
  }

  void _thirds(Canvas canvas) {
    final paint = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.14)
      ..strokeWidth = 1;
    for (final t in [1 / 3, 2 / 3]) {
      canvas.drawLine(
        Offset(frame.left + frame.width * t, frame.top),
        Offset(frame.left + frame.width * t, frame.bottom),
        paint,
      );
      canvas.drawLine(
        Offset(frame.left, frame.top + frame.height * t),
        Offset(frame.right, frame.top + frame.height * t),
        paint,
      );
    }
  }

  void _corners(Canvas canvas) {
    final paint = Paint()
      ..color = AppSplashColors.glow.changeOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final length =
        frame.shortestSide * EvidenceFrameGeometry.cornerLengthFactor;

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * length, 0), paint);
      canvas.drawLine(origin, origin.translate(0, dy * length), paint);
    }

    corner(frame.topLeft, 1, 1);
    corner(frame.topRight, -1, 1);
    corner(frame.bottomLeft, 1, -1);
    corner(frame.bottomRight, -1, -1);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        frame,
        const Radius.circular(EvidenceFrameGeometry.cornerRadius),
      ),
      Paint()
        ..color = AppSplashColors.cyan.changeOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _silhouette(Canvas canvas) {
    final stroke = Paint()
      ..color = AppSplashColors.cyan.changeOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (category) {
      case EvidenceCategory.rear:
      case EvidenceCategory.front:
        _endView(canvas, stroke);
      case EvidenceCategory.leftSide:
      case EvidenceCategory.rightSide:
        _sideView(canvas, stroke);
      case EvidenceCategory.licensePlate:
      case EvidenceCategory.damageCloseUp:
      case EvidenceCategory.accidentScene:
        break;
    }
  }

  void _endView(Canvas canvas, Paint stroke) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: frame.center.translate(0, frame.height * 0.06),
        width: frame.width * 0.62,
        height: frame.height * 0.46,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, stroke);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(frame.center.dx, frame.top + frame.height * 0.34),
          width: frame.width * 0.46,
          height: frame.height * 0.16,
        ),
        const Radius.circular(6),
      ),
      stroke,
    );
  }

  void _sideView(Canvas canvas, Paint stroke) {
    final y = frame.center.dy + frame.height * 0.08;
    final path = Path()
      ..moveTo(frame.left + frame.width * 0.16, y)
      ..cubicTo(
        frame.left + frame.width * 0.22,
        y - frame.height * 0.22,
        frame.left + frame.width * 0.38,
        y - frame.height * 0.34,
        frame.left + frame.width * 0.52,
        y - frame.height * 0.22,
      )
      ..cubicTo(
        frame.left + frame.width * 0.68,
        y - frame.height * 0.16,
        frame.left + frame.width * 0.78,
        y - frame.height * 0.08,
        frame.left + frame.width * 0.84,
        y,
      );
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _EvidenceGuidePainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.category != category;
  }
}
