import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/global/design_system/tokens/app_palette.dart';

class AccidentLocationMapCard extends StatelessWidget {
  const AccidentLocationMapCard({super.key});

  static const _mapScale = 1.45;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final radius = context.circularRadius(20);
    final markerSize = context.width(48);
    // The sketch map follows the theme: on a dark surface a light map
    // would glare, so the tones are derived from the current scheme.
    final isDark = context.isDarkTheme;
    final mapFill = isDark
        ? colors.selectedBackgroundColor
        : AppPalette.mapFill;
    final blockFill = isDark
        ? Color.alphaBlend(
            colors.textSecondaryColor.changeOpacity(0.16),
            colors.selectedBackgroundColor,
          )
        : AppPalette.mapBlock;
    final parkFill = isDark
        ? Color.alphaBlend(
            colors.successColor.changeOpacity(0.18),
            colors.selectedBackgroundColor,
          )
        : AppPalette.mapPark;
    final roadFill = isDark ? colors.cardColor : AppPalette.mapRoad;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimaryColor.changeOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: mapFill),
            LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  constrained: false,
                  minScale: 1,
                  maxScale: 2.4,
                  panEnabled: true,
                  scaleEnabled: true,
                  child: SizedBox(
                    width: constraints.maxWidth * _mapScale,
                    height: constraints.maxHeight * _mapScale,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _ConfirmMapPainter(
                            fill: mapFill,
                            block: blockFill,
                            park: parkFill,
                            road: roadFill,
                            accent: colors.brandAccent,
                          ),
                          child: const SizedBox.expand(),
                        ),
                        Align(
                          alignment: const Alignment(0.06, -0.04),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: markerSize,
                            color: AppSplashColors.cyanDeep,
                            shadows: [
                              Shadow(
                                color: AppSplashColors.cyan.changeOpacity(0.55),
                                blurRadius: context.width(18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            PositionedDirectional(
              top: context.height(12),
              end: context.width(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.cardColor.changeOpacity(0.94),
                  borderRadius: context.circularRadius(100),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Padding(
                  padding: context.spaceSymmetric(vertical: 6, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          color: ClaimStatusColors.approved,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: context.width(7),
                          height: context.width(7),
                        ),
                      ),
                      context.addHorizontalSpace(6),
                      Text(
                        strings.locationAccurate,
                        style: context.font14Bold?.copyWith(
                          color: colors.textPrimaryColor,
                          fontWeight: FontWeightHelper.semiBold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmMapPainter extends CustomPainter {
  const _ConfirmMapPainter({
    required this.fill,
    required this.block,
    required this.park,
    required this.road,
    required this.accent,
  });

  final Color fill;
  final Color block;
  final Color park;
  final Color road;
  final Color accent;

  static const _roadWidth = 14.0;
  static const _accentWidth = 2.4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = fill);

    final blockPaint = Paint()..color = block;
    final parkPaint = Paint()..color = park;
    void rounded(Rect rect, Paint paint) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }

    rounded(
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.08,
        size.width * 0.22,
        size.height * 0.2,
      ),
      blockPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.1,
        size.width * 0.18,
        size.height * 0.16,
      ),
      blockPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.64,
        size.height * 0.07,
        size.width * 0.28,
        size.height * 0.24,
      ),
      blockPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.42,
        size.width * 0.26,
        size.height * 0.18,
      ),
      parkPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.4,
        size.width * 0.3,
        size.height * 0.2,
      ),
      blockPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.7,
        size.width * 0.3,
        size.height * 0.2,
      ),
      blockPaint,
    );
    rounded(
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.72,
        size.width * 0.36,
        size.height * 0.18,
      ),
      blockPaint,
    );

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = _roadWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.36),
      Offset(size.width, size.height * 0.36),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.64),
      Offset(size.width, size.height * 0.64),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.32, 0),
      Offset(size.width * 0.32, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.72, size.height),
      roadPaint,
    );

    final accentPaint = Paint()
      ..color = accent.changeOpacity(0.5)
      ..strokeWidth = _accentWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.64),
      Offset(size.width * 0.78, size.height * 0.64),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfirmMapPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.block != block ||
        oldDelegate.park != park ||
        oldDelegate.road != road ||
        oldDelegate.accent != accent;
  }
}
