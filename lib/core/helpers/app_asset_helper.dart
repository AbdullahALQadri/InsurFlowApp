import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';

mixin AppAssetHelper {
  // ==================== SVG ====================

  static Widget svgImage(
      String? path_, {
        Color? color,
        double? width,
        double? height,
        BoxFit fit = BoxFit.contain,
        Widget? placeholderBuilder,
        bool network = false,
        double opacity = 1,
      }) {
    String path = path_ ?? '';
    if (path.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return Opacity(
      opacity: opacity,
      child: !network
          ? SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color?.toColorFilter(),
        placeholderBuilder: placeholderBuilder != null
            ? (_) => placeholderBuilder
            : null,
        errorBuilder: (context, error, stackTrace) => errorImageBuilder,
      )
          : SvgPicture.network(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color?.toColorFilter(),
        placeholderBuilder: placeholderBuilder != null
            ? (_) => placeholderBuilder
            : null,
        errorBuilder: (context, error, stackTrace) => errorImageBuilder,
      ),
    );
  }

  // ==================== LOTTIE ====================

  static Widget lottieImage(
      String? path_, {
        double? width,
        double? height,
        BoxFit fit = BoxFit.contain,
        bool network = false,
        double opacity = 1,
        bool repeat = true,
        bool animate = true,
        Widget? placeholderBuilder,
      }) {
    String path = path_ ?? '';

    if (path.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    return Opacity(
      opacity: opacity,
      child: network
          ? Lottie.network(
        path,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return placeholderBuilder ?? loadingImageBuilder;
          }

          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          return errorImageBuilder;
        },
      )
          : Lottie.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        animate: animate,
        frameBuilder: (context, child, composition) {
          if (composition == null) {
            return placeholderBuilder ?? loadingImageBuilder;
          }

          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          return errorImageBuilder;
        },
      ),
    );
  }

  // ==================== ERROR ====================

  static Widget get errorImageBuilder {
    return const Padding(
      padding: EdgeInsets.all(6),
      child: Icon(Icons.error),
    );
  }

  // ==================== LOADING ====================

  static Widget get loadingImageBuilder {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}