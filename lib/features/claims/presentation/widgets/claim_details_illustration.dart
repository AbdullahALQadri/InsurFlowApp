import 'package:flutter/material.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/helpers/app_asset_helper.dart';

class ClaimDetailsIllustration extends StatelessWidget {
  const ClaimDetailsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.isSmallScreen ? context.width(88) : context.width(104);

    return Center(
      child: AppAssetHelper.lottieImage(
        AppLotties.lottieAssignmentNotice,
        width: size,
        height: size,
        repeat: true,
      ),
    );
  }
}
