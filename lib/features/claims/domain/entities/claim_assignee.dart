/// A person referenced by assignment fields on a claim.
///
/// Maps the nested `assignedTo` / `fieldAdjuster` objects returned by
/// `GET /claims`. Kept separate from `assignedBy`, which is a different
/// concept (the person who assigned the claim) and is not present in
/// the current list response.
class ClaimAssignee {
  const ClaimAssignee({this.id, this.name});

  final String? id;
  final String? name;

  bool get hasValue =>
      (id?.trim().isNotEmpty ?? false) || (name?.trim().isNotEmpty ?? false);
}
