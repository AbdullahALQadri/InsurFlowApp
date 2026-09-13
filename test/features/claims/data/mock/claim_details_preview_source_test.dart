import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/data/mock/claim_details_preview_source.dart';
import 'package:insurflow/features/claims/domain/claim_status.dart';
import 'package:insurflow/features/claims/domain/entities/claim.dart';

void main() {
  const source = ClaimDetailsPreviewSource();

  test('fills only empty product fields', () {
    const sparse = Claim(
      id: '6a91ab09c9ff1dc54fabf15b',
      status: ClaimStatus.assigned,
    );

    final filled = source.fillMissing(sparse);

    expect(filled.id, sparse.id);
    expect(filled.status, ClaimStatus.assigned);
    expect(filled.customerName, 'Ahmed Ali');
    expect(filled.vehicleDisplay, 'Toyota Corolla');
    expect(filled.initialPlateNumber, 'ABC-1234');
    expect(filled.assignedBy, 'Claims Officer');
  });

  test('does not overwrite values returned by the backend', () {
    const fromApi = Claim(
      id: 'abc',
      status: ClaimStatus.assigned,
      customerName: 'Sara N.',
      initialPlateNumber: 'XYZ-999',
      assignedBy: 'Officer Two',
    );

    final filled = source.fillMissing(fromApi);

    expect(filled.customerName, 'Sara N.');
    expect(filled.initialPlateNumber, 'XYZ-999');
    expect(filled.assignedBy, 'Officer Two');
  });
}
