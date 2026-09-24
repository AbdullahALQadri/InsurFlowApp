import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/constants/app_lotties.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/core/extensions/app_sizes.dart';
import 'package:insurflow/core/extensions/navigation.dart';
import 'package:insurflow/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:insurflow/core/extensions/opacity_of_color.dart';
import 'package:insurflow/core/extensions/text_style_extension.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/font_weight/font_weight_helper.dart';
import 'package:insurflow/features/splash/presentation/widgets/splash_atmosphere.dart';
import 'package:insurflow/features/splash/presentation/widgets/splash_brand_mark.dart';
import 'package:insurflow/features/splash/presentation/widgets/splash_flow_lines.dart';
import 'package:lottie/lottie.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _brandName = 'InsurFlow';
  static const _brandTracking = 1.4;
  static const _taglineTracking = 0.6;
  static const _footerTracking = 1.8;

  static const _entranceDuration = Duration(milliseconds: 2800);
  static const _flowDuration = Duration(seconds: 16);

  late final AnimationController _lottieController;
  late final AnimationController _entranceController;
  late final AnimationController _flowController;

  late final Animation<double> _glow;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;
  late final Animation<double> _footerOpacity;
  Timer? _loginTimer;
  var _animationDone = false;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    _entranceController = AnimationController(
      vsync: this,
      duration: _entranceDuration,
    );
    _flowController = AnimationController(
      vsync: this,
      duration: _flowDuration,
    )..repeat();

    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 38),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.38).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.38, end: 0.16).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 38,
      ),
    ]).animate(_entranceController);

    _titleOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.42, 0.68, curve: Curves.easeOut),
    );
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
      ),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.56, 0.82, curve: Curves.easeOut),
    );
    _loaderOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.7, 0.92, curve: Curves.easeOut),
    );
    _footerOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.74, 1.0, curve: Curves.easeOut),
    );

    _entranceController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthSessionRequested());
    });
    _scheduleLogin();
  }

  void _scheduleLogin() {
    _loginTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      _animationDone = true;
      _navigateIfReady(context.read<AuthBloc>().state);
    });
  }

  void _navigateIfReady(AuthState state) {
    if (!_animationDone || !mounted) return;

    // Onboarding runs before sign-in, and only until the user has seen
    // it. An already-authenticated session skips it: they have clearly
    // used the app before.
    final preferences = context.read<AppPreferencesCubit>().state;
    // Acting before the read completes would show onboarding again to
    // someone who has already seen it.
    if (!preferences.isLoaded) return;
    if (state is AuthUnauthenticated && !preferences.hasCompletedOnboarding) {
      context.pushReplacementNamed(Routes.onboardingScreen);
      return;
    }

    if (state is AuthAuthenticated) {
      context.pushReplacementNamed(Routes.mainScreen);
    } else if (state is AuthUnauthenticated) {
      context.pushReplacementNamed(Routes.loginScreen);
    }
  }

  void _onLottieLoaded(LottieComposition composition) {
    _lottieController
      ..duration = composition.duration
      ..forward();
  }

  @override
  void dispose() {
    _loginTimer?.cancel();
    _lottieController.dispose();
    _entranceController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  double _logoSize(BuildContext context) {
    if (context.isLandscape) {
      return context.height(128);
    }
    if (context.isSmallScreen) {
      return context.width(132);
    }
    return context.width(168);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final logoSize = _logoSize(context);
    final overlay = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppSplashColors.midnight,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) => _navigateIfReady(state),
          ),
          // Preferences load asynchronously; re-evaluate when they
          // arrive so a late read still routes correctly.
          BlocListener<AppPreferencesCubit, AppPreferences>(
            listenWhen: (previous, current) =>
                previous.isLoaded != current.isLoaded,
            listener: (context, _) =>
                _navigateIfReady(context.read<AuthBloc>().state),
          ),
        ],
        child: Scaffold(
        backgroundColor: AppSplashColors.midnight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const SplashAtmosphere(),
            SplashFlowLines(progress: _flowController),
            SafeArea(
              child: Padding(
                padding: context.spaceHorizontal(24),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SplashBrandMark(
                                lottie: _lottieController,
                                glow: _glow,
                                asset: AppLotties.lottieSplashLogo,
                                size: logoSize,
                                onLoaded: _onLottieLoaded,
                              ),
                              context.addVerticalSpace(28),
                              FadeTransition(
                                opacity: _titleOpacity,
                                child: SlideTransition(
                                  position: _titleSlide,
                                  child: Text(
                                    _brandName,
                                    textAlign: TextAlign.center,
                                    style:
                                        (context.isSmallScreen
                                                ? context.font26Bold
                                                : context.font28Bold)
                                            ?.copyWith(
                                              color:
                                                  AppSplashColors.textPrimary,
                                              letterSpacing: _brandTracking,
                                              fontWeight:
                                                  FontWeightHelper.semiBold,
                                              height: 1.15,
                                            ),
                                  ),
                                ),
                              ),
                              context.addVerticalSpace(10),
                              FadeTransition(
                                opacity: _taglineOpacity,
                                child: Text(
                                  strings.splashTagline,
                                  textAlign: TextAlign.center,
                                  style: context.font14Regular?.copyWith(
                                    color: AppSplashColors.textMuted,
                                    letterSpacing: _taglineTracking,
                                    fontWeight: FontWeightHelper.regular,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _loaderOpacity,
                      child: SizedBox(
                        width: context.width(18),
                        height: context.width(18),
                        child: CircularProgressIndicator(
                          strokeWidth: context.width(1.6),
                          color: AppSplashColors.cyan.changeOpacity(0.7),
                          backgroundColor: AppSplashColors.cyan.changeOpacity(
                            0.12,
                          ),
                        ),
                      ),
                    ),
                    context.addVerticalSpace(16),
                    FadeTransition(
                      opacity: _footerOpacity,
                      child: Text(
                        strings.splashFooter,
                        textAlign: TextAlign.center,
                        style: context.font14Regular?.copyWith(
                          color: AppSplashColors.textMuted,
                          letterSpacing: _footerTracking,
                          fontWeight: FontWeightHelper.medium,
                          height: 1.2,
                          fontSize: context.width(12),
                        ),
                      ),
                    ),
                    context.addVerticalSpace(20),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
