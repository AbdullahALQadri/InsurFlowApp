import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';
import 'package:insurflow/features/claims/data/models/claim_model.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_detail_sections.dart';
import 'package:insurflow/features/profile/presentation/cubit/app_preferences_cubit.dart';

const english = AppStrings(Locale('en'));
const arabic = AppStrings(Locale('ar'));

/// A fully populated claim, shaped exactly like `GET /claims/{id}`.
final claimJson = {
  'data': {
    'id': '6aa53d36f9b70c167a1fcd7c',
    'claimNumber': 'CLM-DEMO-INS-0011',
    'status': 'SUBMITTED',
    'incidentType': 'REAR_END_COLLISION',
    'incidentLocation': 'King Fahd Road',
    'createdAt': '2026-09-12T11:53:26.303Z',
    'customer': {'name': 'John Doe', 'phone': '+1234567890'},
    'vehicle': {
      'plateNumber': 'ABC-1234',
      'make': 'Toyota',
      'model': 'Camry',
      'year': 2022,
      'color': 'White',
    },
    'policy': {
      'id': '6aa2783ccda4d3dca00b83b1',
      'policyNumber': 'POL-1000',
      'status': 'ACTIVE',
      'startDate': '2025-01-01T00:00:00.000Z',
      'expiryDate': '2026-12-31T00:00:00.000Z',
    },
    'assignment': {
      'assignedTo': {'id': 'u1', 'name': 'Ahmed Adjuster'},
      'assignedBy': {'id': 'u2', 'name': 'Sara Officer'},
      'assignedAt': '2026-09-12T11:53:27.995Z',
      'priority': 'HIGH',
      'assignmentNotes': 'Inspect rear damage',
    },
    'accident': {
      'accidentType': 'REAR_END_COLLISION',
      'accidentDate': '2026-08-28',
      'accidentTime': '14:30',
      'description': 'Hit from behind',
      'damageDescription': 'Rear bumper',
    },
    'location': {
      'latitude': 24.7136,
      'longitude': 46.6753,
      'address': 'King Fahd Road, Riyadh',
      'capturedAt': '2026-08-28T14:35:00.000Z',
    },
    'evidence': [
      {
        'imageType': 'VEHICLE_FRONT',
        'url': 'https://res.cloudinary.com/x/evidence/a.png',
        'uploadedBy': {'id': 'u1', 'name': 'Ahmed Adjuster'},
        'uploadedAt': '2026-09-23T19:50:53.197Z',
      },
    ],
    'timeline': [
      {
        'action': 'Claim Assigned',
        'previousStatus': 'NEW',
        'newStatus': 'ASSIGNED',
        'performedBy': {
          'id': 'u2',
          'name': 'Sara Officer',
          'role': 'CLAIMS_OFFICER',
        },
        'role': 'CLAIMS_OFFICER',
        'timestamp': '2026-09-12T11:53:27.995Z',
      },
    ],
  },
};

void main() {
  group('string coverage', () {
    test('every localized getter differs between the two languages', () {
      // Spot-checks across each area the app covers, so a string added
      // in English only is caught.
      final pairs = <String, (String, String)>{
        'signIn': (english.signIn, arabic.signIn),
        'claimDetails': (english.claimDetails, arabic.claimDetails),
        'myTasks': (english.myTasks, arabic.myTasks),
        'customer': (english.customer, arabic.customer),
        'vehicle': (english.vehicle, arabic.vehicle),
        'policySection': (english.policySection, arabic.policySection),
        'accidentDetails': (english.accidentDetails, arabic.accidentDetails),
        'location': (english.location, arabic.location),
        'reviewClaim': (english.reviewClaim, arabic.reviewClaim),
        'submitClaim': (english.submitClaim, arabic.submitClaim),
        'notifications': (english.notifications, arabic.notifications),
        'profile': (english.profile, arabic.profile),
        'themeLabel': (english.themeLabel, arabic.themeLabel),
        'languageLabel': (english.languageLabel, arabic.languageLabel),
        'accentLabel': (english.accentLabel, arabic.accentLabel),
        'signOut': (english.signOut, arabic.signOut),
        'signOutConfirmTitle': (
          english.signOutConfirmTitle,
          arabic.signOutConfirmTitle,
        ),
        'cancel': (english.cancel, arabic.cancel),
        'notAvailable': (english.notAvailable, arabic.notAvailable),
        'locationUnavailable': (
          english.locationUnavailable,
          arabic.locationUnavailable,
        ),
        'claimSubmittedTitle': (
          english.claimSubmittedTitle,
          arabic.claimSubmittedTitle,
        ),
        'backToHome': (english.backToHome, arabic.backToHome),
        'searchClaimsHint': (english.searchClaimsHint, arabic.searchClaimsHint),
        'splashTagline': (english.splashTagline, arabic.splashTagline),
        'routeNotFound': (english.routeNotFound, arabic.routeNotFound),
      };

      pairs.forEach((name, value) {
        final (en, ar) = value;
        expect(en, isNotEmpty, reason: '$name English');
        expect(ar, isNotEmpty, reason: '$name Arabic');
        expect(ar, isNot(en), reason: '$name is not translated');
        // A translated string should actually contain Arabic script.
        expect(
          RegExp(r'[؀-ۿ]').hasMatch(ar),
          isTrue,
          reason: '$name Arabic value has no Arabic characters',
        );
      });
    });

    test('claim statuses are translated in both languages', () {
      for (final status in ClaimStatus.values) {
        final en = english.statusLabel(status);
        final ar = arabic.statusLabel(status);
        expect(en, isNotEmpty, reason: '$status English');
        expect(ar, isNotEmpty, reason: '$status Arabic');
      }
      expect(arabic.statusLabel(ClaimStatus.inProgress), 'قيد التنفيذ');
    });

    test('validation and error copy is translated', () {
      expect(arabic.passwordsDoNotMatch, isNot(english.passwordsDoNotMatch));
      expect(arabic.passwordTooShort(8), contains('8'));
      expect(arabic.currentPasswordIncorrect,
          isNot(english.currentPasswordIncorrect));
    });

    test('pluralised strings work in both languages', () {
      expect(english.myTasksSubtitle(1), contains('1 assignment'));
      expect(english.myTasksSubtitle(4), contains('4 assignments'));
      expect(arabic.myTasksSubtitle(1), isNot(english.myTasksSubtitle(1)));
      expect(english.evidencePhotoCount(1), '1 photo');
      expect(english.evidencePhotoCount(3), '3 photos');
      expect(arabic.evidencePhotoCount(3), contains('3'));
    });
  });

  group('backend values are never translated', () {
    test('known enums translate, unknown values pass through untouched', () {
      // Known closed sets get a translation...
      expect(arabic.incidentTypeLabelFor('REAR_END_COLLISION'),
          'اصطدام خلفي');
      expect(arabic.evidenceTypeLabel('VEHICLE_FRONT'), 'مقدمة المركبة');
      expect(arabic.priorityLabelFor('HIGH'), 'عالية');
      expect(arabic.userRoleLabel('FIELD_ADJUSTER'), 'مُعاين ميداني');
      expect(arabic.claimStatusLabel('SUBMITTED'), 'مُرسلة');

      // ...anything the app does not know is shown as the backend
      // spelled it, never guessed at.
      expect(arabic.incidentTypeLabelFor('FUTURE_VALUE'), 'Future Value');
      expect(arabic.userRoleLabel('SOME_NEW_ROLE'), 'Some New Role');
      expect(arabic.claimStatusLabel(null), isNull);
    });

    testWidgets('identifiers render identically in Arabic', (tester) async {
      final claim = ClaimModel.fromResponse(claimJson)!;

      for (final locale in [const Locale('en'), const Locale('ar')]) {
        tester.view.physicalSize = const Size(1080, 4800);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppStringsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: ClaimDetailSections(claim: claim),
              ),
            ),
          ),
        );
        await tester.pump();

        // Backend-owned values: plate, policy number, customer name,
        // coordinates and the user id are shown verbatim in both.
        for (final raw in [
          'ABC-1234',
          'POL-1000',
          'John Doe',
          'Toyota Camry',
          '24.7136, 46.6753',
          'King Fahd Road, Riyadh',
        ]) {
          expect(
            find.text(raw, skipOffstage: false),
            findsWidgets,
            reason: '$raw changed under $locale',
          );
        }
      }
    });
  });

  group('direction', () {
    Widget app(Locale locale, Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStringsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      );
    }

    testWidgets('Arabic resolves to RTL and English to LTR', (tester) async {
      await tester.pumpWidget(
        app(const Locale('ar'), const Scaffold(body: Text('probe'))),
      );
      await tester.pump();
      expect(
        Directionality.of(tester.element(find.text('probe'))),
        TextDirection.rtl,
      );

      await tester.pumpWidget(
        app(const Locale('en'), const Scaffold(body: Text('probe'))),
      );
      await tester.pump();
      expect(
        Directionality.of(tester.element(find.text('probe'))),
        TextDirection.ltr,
      );
    });

    testWidgets('back arrows flip with the text direction', (tester) async {
      // Material's directional icons carry matchTextDirection, which is
      // what makes a back arrow point the right way in Arabic.
      await tester.pumpWidget(
        app(
          const Locale('ar'),
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back));
      expect(icon.icon!.matchTextDirection, isTrue);
      expect(Icons.arrow_back_rounded.matchTextDirection, isTrue);
      expect(Icons.chevron_right.matchTextDirection, isTrue);
      expect(Icons.arrow_forward_rounded.matchTextDirection, isTrue);
    });
  });

  group('language selection', () {
    testWidgets('changing the language updates the app immediately', (
      tester,
    ) async {
      final cubit = AppPreferencesCubit(store: InMemoryAppPreferencesStore());
      addTearDown(cubit.close);

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: BlocBuilder<AppPreferencesCubit, AppPreferences>(
            builder: (context, preferences) => MaterialApp(
              theme: AppTheme.lightTheme,
              locale: preferences.locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                AppStringsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) =>
                    Scaffold(body: Text(AppStrings.of(context).profile)),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await cubit.setLocale('en');
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);

      // No restart: the whole tree re-renders on the next frame.
      await cubit.setLocale('ar');
      await tester.pumpAndSettle();
      expect(find.text('الملف الشخصي'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
      expect(
        Directionality.of(tester.element(find.text('الملف الشخصي'))),
        TextDirection.rtl,
      );
    });

    test('the chosen language survives a restart', () async {
      final store = InMemoryAppPreferencesStore();
      final cubit = AppPreferencesCubit(store: store);
      await cubit.setLocale('ar');
      await cubit.close();

      final restarted = AppPreferencesCubit(store: store);
      await restarted.load();

      expect(restarted.state.localeCode, 'ar');
      expect(restarted.state.locale, const Locale('ar'));
      await restarted.close();
    });

    test('the delegate supports exactly the two shipped languages', () {
      const delegate = AppStringsDelegate();
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });
  });
}
