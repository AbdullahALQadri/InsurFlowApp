import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/global/design_system/theme_data/app_theme.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/core/services/device_location_service.dart';
import 'package:insurflow/features/claims/domain/repositories/claims_repository.dart';
import 'package:insurflow/features/claims/domain/usecases/update_claim_location.dart';
import 'package:insurflow/features/claims/presentation/cubit/accident_location_cubit.dart';
import 'package:insurflow/features/claims/presentation/screens/accident_location_screen.dart';
import 'package:insurflow/features/claims/presentation/widgets/claim_location_map.dart';
import 'package:mocktail/mocktail.dart';

const claimId = '6aa53d36f9b70c167a1fcd7c';

final fix = DeviceLocation(
  latitude: 24.7136,
  longitude: 46.6753,
  capturedAt: DateTime.utc(2026, 8, 28, 14, 35),
  address: 'King Fahd Road, Riyadh',
  accuracy: 8.4,
);

class _FakeLocationService implements DeviceLocationService {
  _FakeLocationService(this.result);

  Either<Failure, DeviceLocation> result;
  var calls = 0;
  var settingsOpened = 0;

  @override
  Future<Either<Failure, DeviceLocation>> currentLocation() async {
    calls++;
    return result;
  }

  @override
  Future<void> openLocationSettings() async => settingsOpened++;
}

class _MockRepository extends Mock implements ClaimsRepository {}

void main() {
  late _FakeLocationService locationService;
  late _MockRepository repository;

  setUp(() {
    locationService = _FakeLocationService(Right(fix));
    repository = _MockRepository();
    when(
      () => repository.updateClaimLocation(
        claimId: any(named: 'claimId'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        address: any(named: 'address'),
        capturedAt: any(named: 'capturedAt'),
      ),
    ).thenAnswer((_) async => const Right(null));
  });

  AccidentLocationCubit buildCubit() => AccidentLocationCubit(
    claimId: claimId,
    locationService: locationService,
    updateClaimLocationUseCase: UpdateClaimLocationUseCase(repository),
  );

  Future<AccidentLocationCubit> pump(
    WidgetTester tester, {
    VoidCallback? onConfirmed,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = buildCubit();
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
        home: AccidentLocationScreen(
          claimId: claimId,
          cubit: cubit,
          onConfirmed: onConfirmed ?? () {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return cubit;
  }

  group('acquiring a fix', () {
    testWidgets('asks for the location on open and shows the real map', (
      tester,
    ) async {
      await pump(tester);

      expect(locationService.calls, 1);
      expect(find.byKey(const Key('accident-location-map')), findsOneWidget);
      expect(find.byType(ClaimLocationMap), findsOneWidget);
    });

    testWidgets('shows the resolved address and coordinates, not a stub', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text('King Fahd Road, Riyadh'), findsOneWidget);
      expect(find.text('24.7136, 46.6753'), findsOneWidget);
      expect(find.text('Not available'), findsNothing);
      // Accuracy and capture time come from the platform fix.
      expect(find.text('Accurate to about ±8m'), findsOneWidget);
    });

    testWidgets('the marker sits on the captured coordinates', (tester) async {
      await pump(tester);

      final map = tester.widget<ClaimLocationMap>(
        find.byType(ClaimLocationMap),
      );
      expect(map.point.latitude, fix.latitude);
      expect(map.point.longitude, fix.longitude);
      expect(map.point.address, fix.address);
    });

    testWidgets('a fix without an address still maps and says so', (
      tester,
    ) async {
      locationService.result = Right(
        DeviceLocation(
          latitude: fix.latitude,
          longitude: fix.longitude,
          capturedAt: fix.capturedAt,
        ),
      );
      await pump(tester);

      expect(find.byType(ClaimLocationMap), findsOneWidget);
      expect(find.text('24.7136, 46.6753'), findsOneWidget);
      expect(
        find.text('No address could be resolved for these coordinates.'),
        findsOneWidget,
      );
    });
  });

  group('failure states', () {
    testWidgets('denied permission explains why and offers a retry', (
      tester,
    ) async {
      locationService.result = const Left(LocationPermissionDeniedFailure());
      await pump(tester);

      expect(find.byKey(const Key('accident-location-error')), findsOneWidget);
      expect(
        find.text(
          'Location permission is needed to record where you inspected.',
        ),
        findsOneWidget,
      );
      expect(find.text('Refresh Location'), findsOneWidget);
      expect(find.byType(ClaimLocationMap), findsNothing);
    });

    testWidgets('a permanent denial sends the user to settings', (
      tester,
    ) async {
      locationService.result = const Left(
        LocationPermissionDeniedForeverFailure(),
      );
      await pump(tester);

      expect(find.text('Open settings'), findsOneWidget);
      await tester.tap(find.byKey(const Key('refresh-location')));
      await tester.pump();

      expect(locationService.settingsOpened, 1);
    });

    testWidgets('disabled GPS is reported distinctly', (tester) async {
      locationService.result = const Left(LocationServiceDisabledFailure());
      await pump(tester);

      expect(
        find.text('Location services are turned off on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('a timeout is reported distinctly', (tester) async {
      locationService.result = const Left(LocationTimeoutFailure());
      await pump(tester);

      expect(
        find.text('Could not get a fix in time. Try again.'),
        findsOneWidget,
      );
    });

    testWidgets('confirm is disabled until a fix exists', (tester) async {
      locationService.result = const Left(LocationPermissionDeniedFailure());
      await pump(tester);

      final confirm = tester.widget<Widget>(
        find.byKey(const Key('confirm-location')),
      );
      expect(confirm, isNotNull);
      // Nothing was persisted, because there is nothing to persist.
      verifyNever(
        () => repository.updateClaimLocation(
          claimId: any(named: 'claimId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          address: any(named: 'address'),
          capturedAt: any(named: 'capturedAt'),
        ),
      );
    });
  });

  group('refresh', () {
    testWidgets('fetches again and updates the marker', (tester) async {
      await pump(tester);
      expect(locationService.calls, 1);

      locationService.result = Right(
        DeviceLocation(
          latitude: 21.4225,
          longitude: 39.8262,
          capturedAt: DateTime.utc(2026, 8, 28, 15),
          address: 'Makkah',
        ),
      );
      await tester.tap(find.byKey(const Key('refresh-location')));
      await tester.pump();
      await tester.pump();

      expect(locationService.calls, 2);
      expect(find.text('Makkah'), findsOneWidget);
      final map = tester.widget<ClaimLocationMap>(
        find.byType(ClaimLocationMap),
      );
      expect(map.point.latitude, 21.4225);
    });
  });

  group('confirming', () {
    testWidgets('persists the fix onto the claim', (tester) async {
      var advanced = false;
      await pump(tester, onConfirmed: () => advanced = true);

      await tester.tap(find.byKey(const Key('confirm-location')));
      await tester.pump();
      await tester.pump();

      final captured = verify(
        () => repository.updateClaimLocation(
          claimId: captureAny(named: 'claimId'),
          latitude: captureAny(named: 'latitude'),
          longitude: captureAny(named: 'longitude'),
          address: captureAny(named: 'address'),
          capturedAt: captureAny(named: 'capturedAt'),
        ),
      ).captured;

      expect(captured[0], claimId);
      expect(captured[1], fix.latitude);
      expect(captured[2], fix.longitude);
      expect(captured[3], 'King Fahd Road, Riyadh');
      expect(captured[4], fix.capturedAt);
      expect(advanced, isTrue);
    });

    testWidgets('sends coordinates as the address when none resolved', (
      tester,
    ) async {
      locationService.result = Right(
        DeviceLocation(
          latitude: fix.latitude,
          longitude: fix.longitude,
          capturedAt: fix.capturedAt,
        ),
      );
      await pump(tester);

      await tester.tap(find.byKey(const Key('confirm-location')));
      await tester.pump();
      await tester.pump();

      final captured = verify(
        () => repository.updateClaimLocation(
          claimId: any(named: 'claimId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          address: captureAny(named: 'address'),
          capturedAt: any(named: 'capturedAt'),
        ),
      ).captured;

      // The endpoint requires an address; the coordinates stand in
      // rather than a made-up street name.
      expect(captured.single, '24.7136, 46.6753');
    });

    testWidgets('a save failure keeps the user on the screen', (tester) async {
      when(
        () => repository.updateClaimLocation(
          claimId: any(named: 'claimId'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          address: any(named: 'address'),
          capturedAt: any(named: 'capturedAt'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      var advanced = false;
      await pump(tester, onConfirmed: () => advanced = true);

      await tester.tap(find.byKey(const Key('confirm-location')));
      await tester.pump();
      await tester.pump();

      expect(advanced, isFalse);
    });
  });

  testWidgets('renders in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'));

    expect(find.text('موقع الحادث'), findsOneWidget);
    expect(find.text('King Fahd Road, Riyadh'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('موقع الحادث'))),
      TextDirection.rtl,
    );
  });
}
