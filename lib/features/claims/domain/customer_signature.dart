/// Customer confirmation signature captured during a field inspection.
///
/// TODO(api): `POST /claims/{id}/signature` exists in the Postman
/// collection (see UploadClaimSignatureUseCase in DI). Strokes are
/// still local — wire the upload in the API integration prompt.
/// Do not invent signature routes or response fields.
class CustomerSignature {
  const CustomerSignature({required this.claimId, this.hasInk = false});

  final String claimId;
  final bool hasInk;

  bool get canConfirm => hasInk;

  CustomerSignature captured() {
    return CustomerSignature(claimId: claimId, hasInk: true);
  }

  CustomerSignature cleared() {
    return CustomerSignature(claimId: claimId);
  }
}
