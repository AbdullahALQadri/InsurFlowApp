/// Customer confirmation signature captured during a field inspection.
///
/// TODO(api):
/// Waiting for the Backend signature capture endpoint in the Postman
/// collection. Keep strokes local until a reliable upload contract
/// exists. Do not invent signature routes or response fields.
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
