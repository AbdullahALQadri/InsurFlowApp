import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/claim_documents.dart';

void main() {
  test('starts with three required documents missing and Other optional', () {
    final documents = ClaimDocuments.checklist(claimId: 'CLM-0001');

    expect(documents.slots, hasLength(ClaimDocumentType.values.length));
    expect(documents.requiredTotalCount, 3);
    expect(documents.requiredUploadedCount, 0);
    expect(documents.remainingRequiredCount, 3);
    expect(documents.canContinue, isFalse);
    expect(
      documents.slots
          .firstWhere((slot) => slot.type == ClaimDocumentType.other)
          .isRequired,
      isFalse,
    );
  });

  test('enables continue after the three required documents are uploaded', () {
    var documents = ClaimDocuments.checklist(claimId: 'CLM-0001');

    documents = documents.withUploaded(
      ClaimDocumentType.driverLicense,
      source: DocumentSource.camera,
    );
    documents = documents.withUploaded(
      ClaimDocumentType.nationalId,
      source: DocumentSource.gallery,
    );
    expect(documents.requiredUploadedCount, 2);
    expect(documents.canContinue, isFalse);

    documents = documents.withUploaded(
      ClaimDocumentType.policeReport,
      source: DocumentSource.files,
    );
    expect(documents.requiredUploadedCount, 3);
    expect(documents.canContinue, isTrue);

    documents = documents.withUploaded(ClaimDocumentType.other);
    expect(documents.canContinue, isTrue);
  });

  test('optional Other does not satisfy the required count', () {
    var documents = ClaimDocuments.checklist(claimId: 'CLM-0001');
    documents = documents.withUploaded(ClaimDocumentType.other);

    expect(documents.requiredUploadedCount, 0);
    expect(documents.canContinue, isFalse);
  });
}
