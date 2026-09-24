/// A person referenced by a claim (`assignedTo`, `assignedBy`,
/// `fieldAdjuster`, `createdBy`, `uploadedBy`, `performedBy`).
///
/// `GET /claims` returns only `{id, name}` for `assignedTo` /
/// `fieldAdjuster`. `GET /claims/{id}` additionally returns
/// `employeeCode` everywhere and `role` inside `timeline[].performedBy`.
/// Fields the backend did not send stay null.
class ClaimAssignee {
  const ClaimAssignee({this.id, this.name, this.employeeCode, this.role});

  final String? id;
  final String? name;
  final String? employeeCode;
  final String? role;

  bool get hasValue =>
      (id?.trim().isNotEmpty ?? false) || (name?.trim().isNotEmpty ?? false);

  /// `name` when present, otherwise `employeeCode`. Null when the
  /// backend sent neither — callers render their own empty state.
  String? get displayName {
    final value = name?.trim();
    if (value != null && value.isNotEmpty) return value;
    final code = employeeCode?.trim();
    if (code != null && code.isNotEmpty) return code;
    return null;
  }
}
