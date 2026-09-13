import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/customer_signature.dart';

void main() {
  test('cannot confirm until ink is captured', () {
    const unsigned = CustomerSignature(claimId: 'CLM-0001');
    expect(unsigned.hasInk, isFalse);
    expect(unsigned.canConfirm, isFalse);

    final signed = unsigned.captured();
    expect(signed.hasInk, isTrue);
    expect(signed.canConfirm, isTrue);
    expect(signed.cleared().canConfirm, isFalse);
  });
}
