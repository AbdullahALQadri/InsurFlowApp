import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/error/failures.dart';
import 'package:insurflow/core/network/dio_factory.dart';
import 'package:insurflow/core/network/token_store.dart';
import 'package:insurflow/core/services/adjuster_position_store.dart';
import 'package:insurflow/core/services/device_location_service.dart';
import 'package:insurflow/core/services/location_tracking_service.dart';

/// Captures the outgoing request instead of sending it.
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.requests);

  final List<RequestOptions> requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _StubLocationService implements DeviceLocationService {
  _StubLocationService(this.result);

  Either<Failure, DeviceLocation> result;
  var calls = 0;

  @override
  Future<Either<Failure, DeviceLocation>> currentLocation() async {
    calls++;
    return result;
  }

  @override
  Future<void> openLocationSettings() async {}
}

DeviceLocation fixAt(double lat, double lng, {double? accuracy}) {
  return DeviceLocation(
    latitude: lat,
    longitude: lng,
    capturedAt: DateTime.utc(2026, 9, 25, 10),
    accuracy: accuracy,
  );
}

void main() {
  group('AdjusterPositionStore', () {
    test('sends no headers until the device has produced a fix', () {
      // The alternative would be transmitting an invented position.
      expect(AdjusterPositionStore().headers, isEmpty);
    });

    test('carries the real fix once there is one', () {
      final store = AdjusterPositionStore()
        ..record(fixAt(32.2601972, 35.1288474));

      expect(store.headers, {
        'X-Latitude': '32.2601972',
        'X-Longitude': '35.1288474',
      });
    });

    test('clearing drops the position so the next user cannot inherit it', () {
      final store = AdjusterPositionStore()..record(fixAt(32.26, 35.12));
      store.clear();

      expect(store.latest, isNull);
      expect(store.headers, isEmpty);
    });
  });

  group('request headers', () {
    late List<RequestOptions> requests;
    late AdjusterPositionStore store;
    late Dio dio;

    setUp(() {
      requests = [];
      store = AdjusterPositionStore();
      dio = DioFactory.create(
        tokenStore: InMemoryTokenStore(),
        positionStore: store,
      )..httpClientAdapter = _CapturingAdapter(requests);
    });

    test('an ordinary request carries the position once it is known', () async {
      store.record(fixAt(32.2601972, 35.1288474));
      await dio.get<dynamic>('/claims');

      // The backend reads the adjuster's position off ordinary
      // requests; there is no endpoint that reports it.
      expect(requests.single.headers['X-Latitude'], '32.2601972');
      expect(requests.single.headers['X-Longitude'], '35.1288474');
    });

    test('no fix means no position headers at all', () async {
      await dio.get<dynamic>('/claims');

      expect(requests.single.headers.containsKey('X-Latitude'), isFalse);
      expect(requests.single.headers.containsKey('X-Longitude'), isFalse);
    });

    test('a later fix replaces the one sent before', () async {
      store.record(fixAt(32.26, 35.12));
      await dio.get<dynamic>('/claims');
      store.record(fixAt(31.95, 35.93));
      await dio.get<dynamic>('/claims');

      expect(requests.first.headers['X-Latitude'], '32.26');
      expect(requests.last.headers['X-Latitude'], '31.95');
    });
  });

  group('LocationTrackingService', () {
    test('records a real fix and reports an active GPS', () async {
      final store = AdjusterPositionStore();
      final service = LocationTrackingService(
        locationService: _StubLocationService(
          Right(fixAt(32.26, 35.12, accuracy: 8)),
        ),
        positionStore: store,
      );
      addTearDown(service.dispose);

      await service.refresh();

      expect(store.latest?.latitude, 32.26);
      expect(service.currentStatus, GpsStatus.active);
      expect(service.lastUpdatedTime, isNotNull);
    });

    test('a poor fix is still recorded, but reported as weak', () async {
      final store = AdjusterPositionStore();
      final service = LocationTrackingService(
        locationService: _StubLocationService(
          Right(fixAt(32.26, 35.12, accuracy: 350)),
        ),
        positionStore: store,
      );
      addTearDown(service.dispose);

      await service.refresh();

      // A rough position beats no position.
      expect(store.latest, isNotNull);
      expect(service.currentStatus, GpsStatus.weakGps);
    });

    test('a refused permission never stores a position', () async {
      final store = AdjusterPositionStore();
      final service = LocationTrackingService(
        locationService: _StubLocationService(
          const Left(LocationPermissionDeniedFailure()),
        ),
        positionStore: store,
      );
      addTearDown(service.dispose);

      await service.refresh();

      expect(store.latest, isNull);
      expect(store.headers, isEmpty);
      expect(service.currentStatus, GpsStatus.permissionDenied);
    });

    test('disabled location services are reported as such', () async {
      final service = LocationTrackingService(
        locationService: _StubLocationService(
          const Left(LocationServiceDisabledFailure()),
        ),
        positionStore: AdjusterPositionStore(),
      );
      addTearDown(service.dispose);

      await service.refresh();

      expect(service.currentStatus, GpsStatus.disabled);
    });

    test('a failure leaves the last good fix in place', () async {
      final store = AdjusterPositionStore();
      final location = _StubLocationService(Right(fixAt(32.26, 35.12)));
      final service = LocationTrackingService(
        locationService: location,
        positionStore: store,
      );
      addTearDown(service.dispose);

      await service.refresh();
      location.result = const Left(LocationTimeoutFailure());
      await service.refresh();

      // Stale coordinates are honest; blank ones lose information.
      expect(store.latest?.latitude, 32.26);
      expect(service.currentStatus, GpsStatus.waitingConnection);
    });

    test('stopping ends the polling timer', () async {
      final location = _StubLocationService(Right(fixAt(32.26, 35.12)));
      final service = LocationTrackingService(
        locationService: location,
        positionStore: AdjusterPositionStore(),
        interval: const Duration(milliseconds: 20),
      );
      addTearDown(service.dispose);

      service.start();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      service.stop();
      final afterStop = location.calls;
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(afterStop, greaterThan(1));
      expect(location.calls, afterStop);
    });
  });
}
