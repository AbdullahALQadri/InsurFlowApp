import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:insurflow/core/di/app_dependencies.dart';
import 'package:insurflow/core/global/design_system/app_color/app_splash_colors.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/routing/app_router.dart';
import 'package:insurflow/core/routing/routes.dart';
import 'package:insurflow/core/services/push_notification_service.dart';
import 'package:insurflow/features/notifications/presentation/widgets/notification_gateway.dart';
import 'package:insurflow/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDependencies.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppSplashColors.midnight,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must be registered before runApp so Android can spin up the
  // background isolate for messages that arrive while the app is not in
  // the foreground.
  FirebaseMessaging.onBackgroundMessage(insurFlowBackgroundMessageHandler);

  // Push is an enhancement, never a startup dependency: a device
  // without Play Services, without APNs configured, or with
  // notifications denied must still reach the login screen.
  try {
    await AppDependencies.instance.pushNotificationService.init();
  } catch (error) {
    if (kDebugMode) debugPrint('[push] initialisation skipped: $error');
  }

  runApp(const InsurFlowApp());
}

class InsurFlowApp extends StatelessWidget {
  const InsurFlowApp({super.key, this.appRouter = const AppRouter()});

  final AppRouter appRouter;

  /// Lets a notification tap push a route from outside the widget tree.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => dependencies.createAuthBloc()),
        BlocProvider(create: (_) => dependencies.createNotificationCenterCubit()),
      ],
      child: MaterialApp(
        title: 'InsurFlow',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStringsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: Routes.splashScreen,
        onGenerateRoute: appRouter.generateRoute,
        builder: (context, child) => NotificationGateway(
          service: dependencies.pushNotificationService,
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
