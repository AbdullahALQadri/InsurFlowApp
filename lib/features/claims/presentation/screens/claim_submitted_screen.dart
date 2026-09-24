import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/claim_status_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_submitted_animation.dart';

class ClaimSubmittedArgs {
  const ClaimSubmittedArgs({this.claimNumber});

  /// Shown under the message when the caller carried it through.
  /// `POST /claims/{id}/inspection/submit` returns only `{status}`, so
  /// this is the number already on screen, never a re-fetch.
  final String? claimNumber;
}

/// Confirms a successful inspection submission.
///
/// Reached only after `POST /claims/{id}/inspection/submit` returns
/// success. It is pushed with the inspection stack removed, so the
/// screens behind it are gone and the only way onward is home — which
/// is also what the system back gesture does.
class ClaimSubmittedScreen extends StatelessWidget {
  const ClaimSubmittedScreen({super.key, required this.args, this.onDone});

  final ClaimSubmittedArgs args;

  /// Overridden by tests; production pops back to the home tab.
  final VoidCallback? onDone;

  /// Replaces everything above the home screen, so the finished
  /// inspection cannot be stepped back into.
  static Future<dynamic> open(
    BuildContext context, {
    String? claimNumber,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.claimSubmittedScreen,
      (route) => route.isFirst,
      arguments: ClaimSubmittedArgs(claimNumber: claimNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final claimNumber = args.claimNumber?.trim();
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.backgroundColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    final markSize = context.isSmallScreen
        ? context.width(112)
        : context.width(136);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: PopScope(
        // Back must go home, not back into the submitted inspection.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goHome(context);
        },
        child: Scaffold(
          backgroundColor: colors.backgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: context.spaceSymmetric(
                              vertical: 24,
                              horizontal: 28,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClaimSubmittedAnimation(
                                  key: const Key('claim-submitted-animation'),
                                  size: markSize,
                                ),
                                context.addVerticalSpace(28),
                                Text(
                                  strings.claimSubmittedTitle,
                                  textAlign: TextAlign.center,
                                  style: context.font26Bold?.copyWith(
                                    color: colors.textPrimaryColor,
                                    fontWeight: FontWeightHelper.bold,
                                    height: 1.2,
                                  ),
                                ),
                                context.addVerticalSpace(12),
                                Text(
                                  strings.claimSubmittedBody,
                                  textAlign: TextAlign.center,
                                  style: context.font16Regular?.copyWith(
                                    color: colors.textSecondaryColor,
                                    height: 1.5,
                                  ),
                                ),
                                if (claimNumber != null &&
                                    claimNumber.isNotEmpty) ...[
                                  context.addVerticalSpace(20),
                                  _ClaimNumberChip(claimNumber: claimNumber),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: context.spaceSymmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: AppPrimaryButton(
                    key: const Key('back-to-home'),
                    label: strings.backToHome,
                    prominent: true,
                    onPressed: () => _goHome(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    if (onDone != null) {
      onDone!();
      return;
    }
    // The home screen is the only route left beneath this one.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _ClaimNumberChip extends StatelessWidget {
  const _ClaimNumberChip({required this.claimNumber});

  final String claimNumber;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    const success = ClaimStatusColors.submitted;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: success.changeOpacity(0.10),
        borderRadius: context.circularRadius(100),
        border: Border.all(color: success.changeOpacity(0.28)),
      ),
      child: Padding(
        padding: context.spaceSymmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.submittedClaimLabel,
              style: context.font14Regular?.copyWith(
                color: colors.textSecondaryColor,
                fontSize: context.width(12),
              ),
            ),
            context.addHorizontalSpace(8),
            Flexible(
              child: Text(
                claimNumber,
                overflow: TextOverflow.ellipsis,
                style: context.font16Bold?.copyWith(
                  color: colors.textPrimaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
