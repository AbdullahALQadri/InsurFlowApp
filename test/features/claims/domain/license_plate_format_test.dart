import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/license_plate_format.dart';

void main() {
  group('LicensePlateFormat', () {
    test('formats ABC-1234 as the user types', () {
      expect(LicensePlateFormat.display('a'), 'A');
      expect(LicensePlateFormat.display('ab'), 'AB');
      expect(LicensePlateFormat.display('abc'), 'ABC');
      expect(LicensePlateFormat.display('abc1'), 'ABC-1');
      expect(LicensePlateFormat.display('abc1234'), 'ABC-1234');
      expect(LicensePlateFormat.display('ABC-1234'), 'ABC-1234');
    });

    test('ignores extra characters and leading digits', () {
      expect(LicensePlateFormat.display('1abc1234xyz'), 'ABC-1234');
      expect(LicensePlateFormat.display('ab-c-99'), 'ABC-99');
    });

    test('accepts only three letters and four digits', () {
      expect(LicensePlateFormat.isValid(''), isFalse);
      expect(LicensePlateFormat.isValid('ABC'), isFalse);
      expect(LicensePlateFormat.isValid('ABC-123'), isFalse);
      expect(LicensePlateFormat.isValid('AB-1234'), isFalse);
      expect(LicensePlateFormat.isValid('ABC-1234'), isTrue);
      expect(LicensePlateFormat.isValid('abc1234'), isTrue);
    });
  });
}
