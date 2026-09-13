import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/accident_location.dart';

void main() {
  test('formats demo coordinates to four decimal places', () {
    final location = AccidentLocation.demo(claimId: 'CLM-0001');

    expect(location.street, 'Al-Quds Street');
    expect(location.city, 'Tulkarm');
    expect(location.coordinatesLabel, '32.3100, 35.0300');
    expect(location.capturedAt, DateTime(2026, 8, 24, 16, 42));
  });
}
