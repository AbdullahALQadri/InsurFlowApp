import 'package:insurflow/features/claims/domain/entities/claim_assignee.dart';

/// Value objects for the nested payload of `GET /claims/{id}`.
///
/// Every field here maps 1:1 to a key the backend actually returns.
/// The backend sends `null` for anything not captured yet (a fresh
/// claim has `accident`, `location` and `policy` fully null), so every
/// field is nullable and callers render their own empty state rather
/// than a substituted value.

/// Formats a backend SCREAMING_SNAKE enum for display without changing
/// its meaning: `REAR_END_COLLISION` -> `Rear End Collision`. Values the
/// backend adds later pass through the same way instead of being
/// mapped to an invented label.
String? humanizeEnum(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  return value
      .split(RegExp(r'[_\s]+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : word[0].toUpperCase() + word.substring(1).toLowerCase(),
      )
      .join(' ');
}

/// `customer` — `{name, phone}`.
class ClaimCustomer {
  const ClaimCustomer({this.name, this.phone});

  final String? name;
  final String? phone;

  bool get hasValue =>
      (name?.trim().isNotEmpty ?? false) || (phone?.trim().isNotEmpty ?? false);
}

/// `vehicle` — `{plateNumber, make, model, year, color}`.
///
/// On a claim that has not had its vehicle confirmed yet the backend
/// returns the plate only, with `make`/`model`/`year`/`color` null.
class ClaimVehicleInfo {
  const ClaimVehicleInfo({
    this.plateNumber,
    this.make,
    this.model,
    this.year,
    this.color,
  });

  final String? plateNumber;
  final String? make;
  final String? model;
  final int? year;
  final String? color;

  bool get hasValue =>
      (plateNumber?.trim().isNotEmpty ?? false) || hasSpecification;

  /// True once the vehicle has been resolved against the registry.
  bool get hasSpecification =>
      (make?.trim().isNotEmpty ?? false) ||
      (model?.trim().isNotEmpty ?? false) ||
      year != null ||
      (color?.trim().isNotEmpty ?? false);

  /// `make model`, or whichever half the backend sent. Null when it
  /// sent neither.
  String? get makeModel {
    final parts = [
      if (make?.trim().isNotEmpty ?? false) make!.trim(),
      if (model?.trim().isNotEmpty ?? false) model!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }
}

/// `policy` — `{id, policyNumber, status, startDate, expiryDate}`.
/// The whole object is null until a policy is linked to the claim.
class ClaimPolicy {
  const ClaimPolicy({
    this.id,
    this.policyNumber,
    this.status,
    this.startDate,
    this.expiryDate,
  });

  final String? id;
  final String? policyNumber;
  final String? status;
  final DateTime? startDate;
  final DateTime? expiryDate;

  bool get hasValue =>
      (policyNumber?.trim().isNotEmpty ?? false) ||
      (status?.trim().isNotEmpty ?? false);

  bool get isActive => status?.trim().toUpperCase() == 'ACTIVE';

  String? get statusLabel => humanizeEnum(status);
}

/// `assignment` — `{assignedTo, assignedBy, assignedAt, priority,
/// assignmentNotes}`.
class ClaimAssignmentInfo {
  const ClaimAssignmentInfo({
    this.assignedTo,
    this.assignedBy,
    this.assignedAt,
    this.priority,
    this.assignmentNotes,
  });

  final ClaimAssignee? assignedTo;
  final ClaimAssignee? assignedBy;
  final DateTime? assignedAt;
  final String? priority;
  final String? assignmentNotes;

  bool get hasValue =>
      (assignedTo?.hasValue ?? false) ||
      (assignedBy?.hasValue ?? false) ||
      assignedAt != null ||
      (priority?.trim().isNotEmpty ?? false) ||
      (assignmentNotes?.trim().isNotEmpty ?? false);

  String? get priorityLabel => humanizeEnum(priority);
}

/// `accident` — `{accidentType, accidentDate, accidentTime,
/// description, damageDescription}`. All null until the adjuster
/// submits `PUT /claims/{id}/accident`.
class ClaimAccidentInfo {
  const ClaimAccidentInfo({
    this.accidentType,
    this.accidentDate,
    this.accidentTime,
    this.description,
    this.damageDescription,
  });

  final String? accidentType;

  /// Backend sends `YYYY-MM-DD`; kept as sent when it is not parseable.
  final String? accidentDate;

  /// Backend sends `HH:mm`.
  final String? accidentTime;
  final String? description;
  final String? damageDescription;

  bool get hasValue =>
      (accidentType?.trim().isNotEmpty ?? false) ||
      (accidentDate?.trim().isNotEmpty ?? false) ||
      (accidentTime?.trim().isNotEmpty ?? false) ||
      (description?.trim().isNotEmpty ?? false) ||
      (damageDescription?.trim().isNotEmpty ?? false);

  String? get accidentTypeLabel => humanizeEnum(accidentType);

  DateTime? get accidentDateTime {
    final date = accidentDate?.trim();
    if (date == null || date.isEmpty) return null;
    return DateTime.tryParse(date);
  }
}

/// `location` — `{latitude, longitude, address, capturedAt}`, the GPS
/// fix recorded by the adjuster via `PUT /claims/{id}/location`.
/// Distinct from `incidentCoordinates`, which is filed with the claim.
class ClaimLocationInfo {
  const ClaimLocationInfo({
    this.latitude,
    this.longitude,
    this.address,
    this.capturedAt,
  });

  final double? latitude;
  final double? longitude;
  final String? address;
  final DateTime? capturedAt;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get hasValue => hasCoordinates || (address?.trim().isNotEmpty ?? false);

  String? get coordinatesLabel => hasCoordinates
      ? '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
      : null;
}

/// One entry of `evidence[]` — `{imageType, url, uploadedBy,
/// uploadedAt}`. `uploadedBy` is an id string on the upload response
/// and a populated object on `GET /claims/{id}`.
class ClaimEvidenceItem {
  const ClaimEvidenceItem({
    this.imageType,
    this.url,
    this.uploadedBy,
    this.uploadedAt,
  });

  final String? imageType;
  final String? url;
  final ClaimAssignee? uploadedBy;
  final DateTime? uploadedAt;

  bool get hasImage => url?.trim().isNotEmpty ?? false;

  String? get imageTypeLabel => humanizeEnum(imageType);
}

/// `signature` — `{url, capturedBy, capturedAt}`. Null until the
/// adjuster uploads one.
class ClaimSignatureInfo {
  const ClaimSignatureInfo({this.url, this.capturedBy, this.capturedAt});

  final String? url;
  final ClaimAssignee? capturedBy;
  final DateTime? capturedAt;

  bool get hasImage => url?.trim().isNotEmpty ?? false;
}

/// One entry of `timeline[]` — the claim's audit trail.
/// `previousStatus` / `newStatus` are null on the "Claim Created" entry.
class ClaimTimelineEntry {
  const ClaimTimelineEntry({
    this.action,
    this.previousStatus,
    this.newStatus,
    this.notes,
    this.performedBy,
    this.role,
    this.timestamp,
  });

  final String? action;
  final String? previousStatus;
  final String? newStatus;
  final String? notes;
  final ClaimAssignee? performedBy;
  final String? role;
  final DateTime? timestamp;

  bool get hasStatusTransition =>
      (previousStatus?.trim().isNotEmpty ?? false) &&
      (newStatus?.trim().isNotEmpty ?? false);

  String? get previousStatusLabel => humanizeEnum(previousStatus);

  String? get newStatusLabel => humanizeEnum(newStatus);

  String? get roleLabel => humanizeEnum(role);
}
