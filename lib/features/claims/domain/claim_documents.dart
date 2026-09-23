/// Required claim documents for a field inspection.
///
/// TODO(api): Still no document upload endpoint in the Postman
/// collection (`/claims/{id}/evidence` and `/claims/{id}/signature`
/// exist, but no driver-license/police-report upload). Keep this
/// checklist local until a reliable multipart contract exists.
/// Do not invent upload routes or response fields.
enum ClaimDocumentType { driverLicense, nationalId, policeReport, other }

enum DocumentUploadStatus { missing, uploaded }

enum DocumentSource { camera, gallery, files }

class ClaimDocumentSlot {
  const ClaimDocumentSlot({
    required this.type,
    this.status = DocumentUploadStatus.missing,
    this.source,
  });

  final ClaimDocumentType type;
  final DocumentUploadStatus status;
  final DocumentSource? source;

  bool get isRequired => type != ClaimDocumentType.other;

  bool get isUploaded => status == DocumentUploadStatus.uploaded;

  ClaimDocumentSlot uploaded({DocumentSource? source}) {
    return ClaimDocumentSlot(
      type: type,
      status: DocumentUploadStatus.uploaded,
      source: source ?? this.source,
    );
  }
}

class ClaimDocuments {
  const ClaimDocuments({required this.claimId, required this.slots});

  final String claimId;
  final List<ClaimDocumentSlot> slots;

  static const requiredCount = 3;

  factory ClaimDocuments.checklist({required String claimId}) {
    return ClaimDocuments(
      claimId: claimId,
      slots: [
        for (final type in ClaimDocumentType.values)
          ClaimDocumentSlot(type: type),
      ],
    );
  }

  int get requiredUploadedCount =>
      slots.where((slot) => slot.isRequired && slot.isUploaded).length;

  int get requiredTotalCount => slots.where((slot) => slot.isRequired).length;

  int get remainingRequiredCount =>
      slots.where((slot) => slot.isRequired && !slot.isUploaded).length;

  bool get canContinue =>
      slots.every((slot) => !slot.isRequired || slot.isUploaded);

  ClaimDocuments withUploaded(
    ClaimDocumentType type, {
    DocumentSource? source,
  }) {
    return ClaimDocuments(
      claimId: claimId,
      slots: [
        for (final slot in slots)
          if (slot.type == type) slot.uploaded(source: source) else slot,
      ],
    );
  }
}
