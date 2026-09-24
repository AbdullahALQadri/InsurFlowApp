import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/core/l10n/app_strings.dart';
import 'package:insurflow/features/claims/presentation/utils/claim_date_formatter.dart';

const english = AppStrings(Locale('en'));
const arabic = AppStrings(Locale('ar'));

void main() {
  group('English', () {
    test('formats a policy coverage range with padded days', () {
      expect(
        ClaimDateFormatter.dateRange(
          english,
          DateTime(2026, 1, 1),
          DateTime(2026, 12, 31),
        ),
        '01 Jan 2026 — 31 Dec 2026',
      );
    });

    test('formats a captured inspection stamp', () {
      expect(
        ClaimDateFormatter.capturedAt(english, DateTime(2026, 8, 24, 16, 42)),
        '24 Aug 2026 · 4:42 PM',
      );
    });

    test('names today and yesterday', () {
      final now = DateTime(2026, 8, 24, 18);
      expect(
        ClaimDateFormatter.lastUpdated(
          english,
          DateTime(2026, 8, 24, 9, 5),
          now: now,
        ),
        'Today, 9:05 AM',
      );
      expect(
        ClaimDateFormatter.lastUpdated(
          english,
          DateTime(2026, 8, 23, 21, 30),
          now: now,
        ),
        'Yesterday, 9:30 PM',
      );
    });

    test('formats relative ages', () {
      final now = DateTime(2026, 8, 24, 12);
      expect(
        ClaimDateFormatter.relative(
          english,
          now.subtract(const Duration(minutes: 20)),
          now: now,
        ),
        '20m ago',
      );
      expect(
        ClaimDateFormatter.relative(
          english,
          now.subtract(const Duration(hours: 5)),
          now: now,
        ),
        '5h ago',
      );
      expect(
        ClaimDateFormatter.relative(
          english,
          now.subtract(const Duration(days: 3)),
          now: now,
        ),
        '3d ago',
      );
    });
  });

  group('Arabic', () {
    test('uses Arabic month names and meridiem', () {
      expect(
        ClaimDateFormatter.capturedAt(arabic, DateTime(2026, 8, 24, 16, 42)),
        '24 أغسطس 2026 · 4:42 م',
      );
      expect(
        ClaimDateFormatter.dayMonthYear(arabic, DateTime(2026, 1, 1)),
        '01 يناير 2026',
      );
    });

    test('names today and yesterday in Arabic', () {
      final now = DateTime(2026, 8, 24, 18);
      expect(
        ClaimDateFormatter.lastUpdated(
          arabic,
          DateTime(2026, 8, 24, 9, 5),
          now: now,
        ),
        'اليوم, 9:05 ص',
      );
    });

    test('formats relative ages in Arabic', () {
      final now = DateTime(2026, 8, 24, 12);
      expect(
        ClaimDateFormatter.relative(
          arabic,
          now.subtract(const Duration(hours: 5)),
          now: now,
        ),
        'قبل 5 س',
      );
    });

    test('keeps Western numerals so backend values stay readable', () {
      final formatted = ClaimDateFormatter.dayMonthYear(
        arabic,
        DateTime(2026, 3, 7),
      );
      expect(formatted, contains('2026'));
      expect(formatted, contains('07'));
    });
  });
}
