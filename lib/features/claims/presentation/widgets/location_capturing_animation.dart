import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';

class LocationCapturingAnimation extends StatelessWidget {
  const LocationCapturingAnimation({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppAssetHelper.lottieImage(
      AppLotties.lottieLocationCapturing,
      width: size,
      height: size,
      placeholderBuilder: SizedBox(width: size, height: size),
    );
  }
}
