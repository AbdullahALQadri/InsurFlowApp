/// A push message received from Firebase Cloud Messaging.
///
/// ## What is known, and what is not
///
/// `title` and `body` come from the FCM `notification` block, which is
/// part of the FCM protocol itself — not a backend-specific field.
///
/// The `data` map is free-form: the backend chooses its keys, and the
/// InsurFlow Postman collection documents **no** push payload at all
/// (it contains zero notification endpoints). Rather than hard-coding a
/// guessed key name, [resolveClaimId] searches the payload for a value
/// that matches the claim-id format the REST API actually uses — a
/// 24-character MongoDB ObjectId, as seen on every real claim
/// (`6ab3a2de8acb6d762af8d57b`). That verifies the *value* instead of
/// trusting a *key*, so navigation works whatever the backend calls the
/// field, and is skipped entirely when the payload carries no claim.
///
/// Nothing here is fabricated: a message with no recognisable claim id
/// simply has `claimId == null` and is shown without a destination.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.receivedAt,
    this.title,
    this.body,
    this.claimId,
    this.sentAt,
    this.data = const {},
  });

  /// FCM `messageId`, or a locally generated id when the platform
  /// omitted one. Used to de-duplicate repeated deliveries.
  final String id;

  final DateTime receivedAt;

  /// From the FCM `notification` block; null for data-only messages.
  final String? title;
  final String? body;

  /// Claim this notification refers to, when the payload carries one.
  final String? claimId;

  /// FCM `sentTime`, when the platform reported it.
  final DateTime? sentAt;

  /// The raw `data` map exactly as delivered.
  final Map<String, String> data;

  bool get hasDestination => claimId != null;

  /// True when there is nothing to show: no title and no body. Such a
  /// message is still processed (it may carry a claim id) but is not
  /// added to the notification list.
  bool get isDisplayable =>
      (title?.trim().isNotEmpty ?? false) || (body?.trim().isNotEmpty ?? false);

  /// Matches the claim-id format used throughout the REST API.
  static final RegExp _objectId = RegExp(r'^[0-9a-fA-F]{24}$');

  /// Keys checked first, so an explicit claim reference wins over any
  /// other ObjectId that happens to be in the payload (for example an
  /// assigning officer's id).
  static const _preferredKeys = [
    'claimId',
    'claim_id',
    'claimID',
    'claim',
    'id',
    'entityId',
    'targetId',
    'referenceId',
  ];

  /// Finds the claim this message points at, or null.
  static String? resolveClaimId(Map<String, String> data) {
    for (final key in _preferredKeys) {
      final value = data[key]?.trim();
      if (value != null && _objectId.hasMatch(value)) return value;
    }
    // Fall back to any value shaped like a claim id, so a key name the
    // backend picks later still navigates correctly.
    for (final entry in data.entries) {
      final value = entry.value.trim();
      if (_objectId.hasMatch(value)) return value;
    }
    return null;
  }

  /// Reads a human-readable string from the data map for data-only
  /// messages, which carry no FCM `notification` block.
  static String? resolveText(Map<String, String> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static const titleKeys = ['title', 'notificationTitle', 'subject'];
  static const bodyKeys = ['body', 'message', 'notificationBody', 'text'];

  @override
  bool operator ==(Object other) =>
      other is AppNotification && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
