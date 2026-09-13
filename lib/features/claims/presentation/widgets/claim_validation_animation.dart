import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';

class ClaimValidationAnimation extends StatelessWidget {
  const ClaimValidationAnimation({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppAssetHelper.lottieImage(
      AppLotties.lottieClaimValidation,
      width: size,
      height: size,
      placeholderBuilder: SizedBox(width: size, height: size),
    );
  }
}
