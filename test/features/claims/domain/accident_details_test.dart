import 'package:flutter_test/flutter_test.dart';
import 'package:insurflow/features/claims/domain/accident_details.dart';

void main() {
  final now = DateTime(2026, 8, 31, 10, 30);

  AccidentDetailsDraft draft({
    AccidentType? type = AccidentType.rearEndCollision,
    DateTime? occurredOn,
    int? hour = 9,
    int? minute = 15,
    String description = 'The insured vehicle was struck from behind.',
    String damageDescription = 'Rear bumper creased and cracked.',
  }) {
    return AccidentDetailsDraft(
      type: type,
      occurredOn: occurredOn ?? DateTime(2026, 8, 31),
      hour: hour,
      minute: minute,
      description: description,
      damageDescription: damageDescription,
    );
  }

  test('accepts a complete on-scene report', () {
    expect(draft().validate(now: now), isEmpty);
  });

  test('requires accident type, descriptions, date, and time', () {
    final issues = const AccidentDetailsDraft().validate(now: now);

    expect(issues[AccidentField.type], AccidentFieldIssue.missing);
    expect(issues[AccidentField.date], AccidentFieldIssue.missing);
    expect(issues[AccidentField.time], AccidentFieldIssue.missing);
    expect(issues[AccidentField.description], AccidentFieldIssue.missing);
    expect(issues[AccidentField.damage], AccidentFieldIssue.missing);
  });

  test('rejects future dates and short descriptions', () {
    final issues = draft(
      occurredOn: DateTime(2026, 9, 1),
      hour: 8,
      minute: 0,
      description: 'Too short',
      damageDescription: 'Dents',
    ).validate(now: now);

    expect(issues[AccidentField.date], AccidentFieldIssue.inFuture);
    expect(issues[AccidentField.description], AccidentFieldIssue.tooShort);
    expect(issues[AccidentField.damage], AccidentFieldIssue.tooShort);
  });

  test('rejects a time later than now on the same day', () {
    final issues = draft(hour: 11, minute: 0).validate(now: now);
    expect(issues[AccidentField.time], AccidentFieldIssue.inFuture);
  });
}
