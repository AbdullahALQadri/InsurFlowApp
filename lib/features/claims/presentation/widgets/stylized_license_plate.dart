import 'package:flutter/material.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';

class StylizedLicensePlate extends StatelessWidget {
  const StylizedLicensePlate({
    super.key,
    required this.plateNumber,
    this.height,
    this.muted = false,
  });

  final String plateNumber;
  final double? height;
  final bool muted;

  static const _boltSize = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final plateHeight = height ?? context.height(96);
    final plateWidth = plateHeight * 3.15;

    return Center(
      child: SizedBox(
        width: plateWidth,
        child: AspectRatio(
          aspectRatio: 3.15,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F1E8),
              borderRadius: context.circularRadius(10),
              border: Border.all(color: const Color(0xFF1A2332), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: colors.textPrimaryColor.changeOpacity(
                    muted ? 0.06 : 0.12,
                  ),
                  blurRadius: muted ? 10 : 18,
                  offset: Offset(0, muted ? 4 : 8),
                ),
              ],
            ),
            child: Padding(
              padding: context.spaceAroundAll(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: context.circularRadius(6),
                  border: Border.all(
                    color: const Color(0xFF2C3A4F).changeOpacity(0.35),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: const Radius.circular(5),
                        bottomStart: const Radius.circular(5),
                      ).resolve(Directionality.of(context)),
                      child: SizedBox(
                        width: context.width(36),
                        child: ColoredBox(
                          color: const Color(0xFF12344C),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'PS',
                                style: context.font14Bold?.copyWith(
                                  color: Colors.white,
                                  fontSize: context.width(10),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeightHelper.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          PositionedDirectional(
                            start: context.width(8),
                            top: context.height(6),
                            child: const _PlateBolt(),
                          ),
                          PositionedDirectional(
                            end: context.width(8),
                            top: context.height(6),
                            child: const _PlateBolt(),
                          ),
                          PositionedDirectional(
                            start: context.width(8),
                            bottom: context.height(6),
                            child: const _PlateBolt(),
                          ),
                          PositionedDirectional(
                            end: context.width(8),
                            bottom: context.height(6),
                            child: const _PlateBolt(),
                          ),
                          Center(
                            child: Padding(
                              padding: context.spaceHorizontal(10),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  plateNumber,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: context.font34Bold?.copyWith(
                                    color: muted
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF111827),
                                    fontWeight: FontWeightHelper.bold,
                                    letterSpacing: 2.6,
                                    height: 1,
                                    fontSize: context.width(32),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlateBolt extends StatelessWidget {
  const _PlateBolt();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF9CA3AF).changeOpacity(0.55),
        border: Border.all(color: const Color(0xFF6B7280), width: 0.8),
      ),
      child: SizedBox(
        width: context.width(StylizedLicensePlate._boltSize),
        height: context.width(StylizedLicensePlate._boltSize),
      ),
    );
  }
}
