import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';

void main() {
  test('formats a policy coverage range with padded days', () {
    expect(
      ClaimDateFormatter.dateRange(
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
      ),
      '01 Jan 2026 — 31 Dec 2026',
    );
  });

  test('formats a captured inspection stamp', () {
    expect(
      ClaimDateFormatter.capturedAt(DateTime(2026, 8, 24, 16, 42)),
      '24 Aug 2026 · 4:42 PM',
    );
  });
}
