import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_location_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_capture_status.dart';
import 'package:insurflow/features/claims/presentation/widgets/location_capturing_animation.dart';

class CapturingLocationArgs {
  const CapturingLocationArgs({required this.claimId});

  final String claimId;
}

class CapturingLocationScreen extends StatefulWidget {
  const CapturingLocationScreen({
    super.key,
    required this.args,
    this.acquireDuration = const Duration(milliseconds: 2800),
    this.onComplete,
  });

  final CapturingLocationArgs args;
  final Duration acquireDuration;
  final VoidCallback? onComplete;

  static Future<dynamic> open(
    BuildContext context, {
    required String claimId,
    bool replace = false,
  }) {
    final route = Routes.capturingLocationScreen;
    final arguments = CapturingLocationArgs(claimId: claimId);
    if (replace) {
      return context.pushReplacementNamed(route, arguments: arguments);
    }
    return context.pushNamed(route, arguments: arguments);
  }

  @override
  State<CapturingLocationScreen> createState() =>
      _CapturingLocationScreenState();
}

class _CapturingLocationScreenState extends State<CapturingLocationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;
  var _notifiedComplete = false;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(
      vsync: this,
      duration: widget.acquireDuration,
    );
    _timeline.addStatusListener(_onStatus);
    if (widget.acquireDuration == Duration.zero) {
      _timeline.value = 1;
      _notifyComplete();
    } else {
      _timeline.forward();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _notifyComplete();
    }
  }

  void _notifyComplete() {
    if (_notifiedComplete) return;
    _notifiedComplete = true;
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The location screen acquires the real fix itself and shows
      // its own loading state, so this hands over the claim id only.
      AccidentLocationScreen.open(
        context,
        claimId: widget.args.claimId,
        replace: true,
      );
    });
  }

  @override
  void dispose() {
    _timeline.removeStatusListener(_onStatus);
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final lottieSize = context.isSmallScreen
        ? context.height(220)
        : context.height(268);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: colors.cardColor,
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        key: ValueKey(widget.args.claimId),
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: context.spaceSymmetric(vertical: 8, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textPrimaryColor,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LocationCapturingAnimation(size: lottieSize),
                              context.addVerticalSpace(8),
                              Text(
                                strings.gettingYourLocation,
                                textAlign: TextAlign.center,
                                style: context.font22Bold?.copyWith(
                                  color: colors.textPrimaryColor,
                                  fontWeight: FontWeightHelper.bold,
                                  height: 1.2,
                                ),
                              ),
                              context.addVerticalSpace(12),
                              Text(
                                strings.searchingMostAccuratePosition,
                                textAlign: TextAlign.center,
                                style: context.font16Regular?.copyWith(
                                  color: colors.textSecondaryColor,
                                  height: 1.45,
                                ),
                              ),
                              context.addVerticalSpace(28),
                              const LocationCaptureStatus(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
