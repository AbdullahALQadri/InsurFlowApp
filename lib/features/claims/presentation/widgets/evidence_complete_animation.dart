import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';

class EvidenceCompleteAnimation extends StatelessWidget {
  const EvidenceCompleteAnimation({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppAssetHelper.lottieImage(
      AppLotties.lottieEvidenceCameraComplete,
      width: size,
      height: size,
      repeat: false,
      placeholderBuilder: SizedBox(width: size, height: size),
    );
  }
}
