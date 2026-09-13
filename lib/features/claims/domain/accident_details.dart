enum AccidentType { rearEnd, front, side, multipleVehicle, other }

extension AccidentTypeApi on AccidentType {
  /// Values follow the Postman example `REAR_END_COLLISION` plus the
  /// matching collision labels used in the Field Adjuster UI.
  String get apiValue {
    switch (this) {
      case AccidentType.rearEnd:
        return 'REAR_END_COLLISION';
      case AccidentType.front:
        return 'FRONT_COLLISION';
      case AccidentType.side:
        return 'SIDE_COLLISION';
      case AccidentType.multipleVehicle:
        return 'MULTIPLE_VEHICLE_COLLISION';
      case AccidentType.other:
        return 'OTHER';
    }
  }
}

enum AccidentField { type, date, time, description, damage }

enum AccidentFieldIssue { missing, inFuture, tooShort }

class AccidentDetailsDraft {
  const AccidentDetailsDraft({
    this.type,
    this.occurredOn,
    this.hour,
    this.minute,
    this.description = '',
    this.damageDescription = '',
  });

  final AccidentType? type;
  final DateTime? occurredOn;
  final int? hour;
  final int? minute;
  final String description;
  final String damageDescription;

  static const minDescriptionLength = 12;
  static const minDamageLength = 10;

  DateTime? get occurredAt {
    final date = occurredOn;
    if (date == null || hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour!, minute!);
  }

  Map<AccidentField, AccidentFieldIssue> validate({DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final issues = <AccidentField, AccidentFieldIssue>{};

    if (type == null) {
      issues[AccidentField.type] = AccidentFieldIssue.missing;
    }

    if (occurredOn == null) {
      issues[AccidentField.date] = AccidentFieldIssue.missing;
    } else {
      final date = DateTime(
        occurredOn!.year,
        occurredOn!.month,
        occurredOn!.day,
      );
      if (date.isAfter(today)) {
        issues[AccidentField.date] = AccidentFieldIssue.inFuture;
      }
    }

    if (hour == null || minute == null) {
      issues[AccidentField.time] = AccidentFieldIssue.missing;
    } else if (occurredOn != null) {
      final occurred = DateTime(
        occurredOn!.year,
        occurredOn!.month,
        occurredOn!.day,
        hour!,
        minute!,
      );
      if (occurred.isAfter(current)) {
        issues[AccidentField.time] = AccidentFieldIssue.inFuture;
      }
    }

    final story = description.trim();
    if (story.isEmpty) {
      issues[AccidentField.description] = AccidentFieldIssue.missing;
    } else if (story.length < minDescriptionLength) {
      issues[AccidentField.description] = AccidentFieldIssue.tooShort;
    }

    final damage = damageDescription.trim();
    if (damage.isEmpty) {
      issues[AccidentField.damage] = AccidentFieldIssue.missing;
    } else if (damage.length < minDamageLength) {
      issues[AccidentField.damage] = AccidentFieldIssue.tooShort;
    }

    return issues;
  }

  bool isComplete(AccidentField field, {DateTime? now}) {
    return !validate(now: now).containsKey(field);
  }
}
