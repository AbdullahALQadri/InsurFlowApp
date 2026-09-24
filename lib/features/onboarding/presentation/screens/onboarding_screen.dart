import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/core/global/design_system/theme_data/theme_extension.dart';
import 'package:insurflow/core/global/design_system/widgets/app_primary_button.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/features/onboarding/presentation/widgets/onboarding_illustration.dart';
import 'package:insurflow/features/onboarding/presentation/widgets/onboarding_progress.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';

/// One onboarding page: a real step of the Field Adjuster workflow.
class _Page {
  const _Page({required this.art, required this.title, required this.body});

  final OnboardingArt art;
  final String Function(AppStrings) title;
  final String Function(AppStrings) body;
}

/// Introduces what this app actually does, in the order the adjuster
/// does it: accept an assignment, identify the vehicle from its plate,
/// record the accident and location on site, capture evidence and a
/// signature, then review and submit.
///
/// Shown once. Finishing or skipping both persist the same flag, so it
/// never appears again until the app is reinstalled.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinished});

  /// Overridden by tests; production marks onboarding done and routes on.
  final VoidCallback? onFinished;

  static const pages = <_Page>[
    _Page(
      art: OnboardingArt.assignments,
      title: _titleAssignments,
      body: _bodyAssignments,
    ),
    _Page(
      art: OnboardingArt.vehicle,
      title: _titleVehicle,
      body: _bodyVehicle,
    ),
    _Page(art: OnboardingArt.scene, title: _titleScene, body: _bodyScene),
    _Page(
      art: OnboardingArt.evidence,
      title: _titleEvidence,
      body: _bodyEvidence,
    ),
    _Page(art: OnboardingArt.submit, title: _titleSubmit, body: _bodySubmit),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Top-level so the page list can stay const.
String _titleAssignments(AppStrings s) => s.onboardingAssignmentsTitle;
String _bodyAssignments(AppStrings s) => s.onboardingAssignmentsBody;
String _titleVehicle(AppStrings s) => s.onboardingVehicleTitle;
String _bodyVehicle(AppStrings s) => s.onboardingVehicleBody;
String _titleScene(AppStrings s) => s.onboardingSceneTitle;
String _bodyScene(AppStrings s) => s.onboardingSceneBody;
String _titleEvidence(AppStrings s) => s.onboardingEvidenceTitle;
String _bodyEvidence(AppStrings s) => s.onboardingEvidenceBody;
String _titleSubmit(AppStrings s) => s.onboardingSubmitTitle;
String _bodySubmit(AppStrings s) => s.onboardingSubmitBody;

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  /// Fractional page offset, so the progress bar and parallax track the
  /// drag rather than snapping on page change.
  var _position = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final page = _controller.page;
    if (page == null || page == _position) return;
    setState(() => _position = page);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  int get _index => _position.round().clamp(0, OnboardingScreen.pages.length - 1);

  bool get _isLast => _index == OnboardingScreen.pages.length - 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);
    final pages = OnboardingScreen.pages;
    final compact = context.isSmallScreen;

    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: context.isDarkTheme
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: colors.backgroundColor,
      systemNavigationBarIconBrightness: context.isDarkTheme
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                onSkip: _finish,
                // Skip disappears on the last page, where the primary
                // action already ends onboarding.
                showSkip: !_isLast,
              ),
              Expanded(
                child: PageView.builder(
                  key: const Key('onboarding-pager'),
                  controller: _controller,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    // Distance from the settled position, used for a
                    // gentle parallax and fade as pages slide past.
                    final delta = (_position - index).clamp(-1.0, 1.0);
                    final settled = 1 - delta.abs();

                    return _OnboardingPage(
                      page: pages[index],
                      strings: strings,
                      delta: delta,
                      settled: settled,
                      compact: compact,
                    );
                  },
                ),
              ),
              Padding(
                padding: context.spaceSymmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    OnboardingProgress(
                      count: pages.length,
                      position: _position,
                    ),
                    context.addVerticalSpace(20),
                    AppPrimaryButton(
                      key: const Key('onboarding-primary-action'),
                      label: _isLast
                          ? strings.onboardingGetStarted
                          : strings.onboardingNext,
                      prominent: true,
                      onPressed: _isLast ? _finish : _next,
                    ),
                    context.addVerticalSpace(10),
                    // Reserves the row's height so the layout does not
                    // jump when Back appears.
                    SizedBox(
                      height: context.height(30),
                      child: AnimatedOpacity(
                        opacity: _index == 0 ? 0 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: TextButton(
                          key: const Key('onboarding-back'),
                          onPressed: _index == 0 ? null : _back,
                          child: Text(
                            strings.onboardingBack,
                            style: context.font14Bold?.copyWith(
                              color: colors.textSecondaryColor,
                              fontWeight: FontWeightHelper.semiBold,
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
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  /// Completing and skipping are the same outcome: the user has seen
  /// onboarding, so the flag is stored either way.
  void _finish() {
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    context.read<AppPreferencesCubit>().completeOnboarding();
    Navigator.of(context).pushReplacementNamed(Routes.loginScreen);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip, required this.showSkip});

  final VoidCallback onSkip;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = AppStrings.of(context);

    return Padding(
      padding: context.spaceSymmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Spacer(),
          AnimatedOpacity(
            opacity: showSkip ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              key: const Key('onboarding-skip'),
              onPressed: showSkip ? onSkip : null,
              child: Text(
                strings.onboardingSkip,
                style: context.font14Bold?.copyWith(
                  color: colors.textSecondaryColor,
                  fontWeight: FontWeightHelper.semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.strings,
    required this.delta,
    required this.settled,
    required this.compact,
  });

  final _Page page;
  final AppStrings strings;
  final double delta;
  final double settled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: context.spaceSymmetric(vertical: 8, horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The art drifts slightly faster than the text, which
                  // is what gives the swipe its depth.
                  Transform.translate(
                    offset: Offset(-delta * constraints.maxWidth * 0.18, 0),
                    child: Opacity(
                      opacity: settled.clamp(0.0, 1.0),
                      child: SizedBox(
                        width: compact
                            ? context.width(210)
                            : context.width(260),
                        child: OnboardingIllustration(
                          art: page.art,
                          progress: settled,
                        ),
                      ),
                    ),
                  ),
                  context.addVerticalSpace(compact ? 20 : 36),
                  Transform.translate(
                    offset: Offset(-delta * constraints.maxWidth * 0.08, 0),
                    child: Opacity(
                      opacity: settled.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            page.title(strings),
                            textAlign: TextAlign.center,
                            style:
                                (compact
                                        ? context.font22Bold
                                        : context.font26Bold)
                                    ?.copyWith(
                                      color: colors.textPrimaryColor,
                                      fontWeight: FontWeightHelper.bold,
                                      height: 1.25,
                                      letterSpacing: -0.2,
                                    ),
                          ),
                          context.addVerticalSpace(12),
                          Text(
                            page.body(strings),
                            textAlign: TextAlign.center,
                            style: context.font16Regular?.copyWith(
                              color: colors.textSecondaryColor.changeOpacity(
                                0.95,
                              ),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
