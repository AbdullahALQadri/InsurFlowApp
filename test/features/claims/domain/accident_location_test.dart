import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/accident_location.dart';

void main() {
  test('formats coordinates to four decimal places', () {
    final location = AccidentLocation(
      claimId: 'CLM-0001',
      street: 'Al-Quds Street',
      city: 'Tulkarm',
      latitude: 32.31,
      longitude: 35.03,
      capturedAt: DateTime(2026, 8, 24, 16, 42),
    );

    expect(location.street, 'Al-Quds Street');
    expect(location.city, 'Tulkarm');
    expect(location.coordinatesLabel, '32.3100, 35.0300');
    expect(location.hasCoordinates, isTrue);
    expect(location.capturedAt, DateTime(2026, 8, 24, 16, 42));
  });

  test('pending location carries no fabricated data', () {
    final location = AccidentLocation.pending(claimId: 'CLM-0001');

    expect(location.claimId, 'CLM-0001');
    expect(location.street, isEmpty);
    expect(location.city, isEmpty);
    expect(location.hasCoordinates, isFalse);
  });
}
