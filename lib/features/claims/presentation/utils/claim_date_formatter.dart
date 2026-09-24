import 'package:insurflow/core/l10n/app_strings.dart';

/// Formats claim timestamps for display.
///
/// Every method takes [AppStrings] so month names, "Today"/"Yesterday"
/// and the AM/PM marker come from the active language rather than being
/// fixed to English.
///
/// Numerals stay Western (`14:30`, `28 Aug 2026`) in both languages:
/// that is what the backend returns and what Saudi and Gulf interfaces
/// conventionally show, and it keeps a claim number or a plate readable
/// next to a date.
class ClaimDateFormatter {
  ClaimDateFormatter._();

  static String lastUpdated(
    AppStrings strings,
    DateTime time, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final date = DateTime(time.year, time.month, time.day);
    final clock = _time(strings, time);

    if (date == today) return '${strings.today}, $clock';
    if (date == today.subtract(const Duration(days: 1))) {
      return '${strings.yesterday}, $clock';
    }
    return '${time.day} ${_month(strings, time)}, $clock';
  }

  static String assignedOn(AppStrings strings, DateTime time) {
    return '${time.day} ${_month(strings, time)} ${time.year}';
  }

  static String dayMonthYear(AppStrings strings, DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    return '$day ${_month(strings, time)} ${time.year}';
  }

  static String dateRange(AppStrings strings, DateTime start, DateTime end) {
    return '${dayMonthYear(strings, start)} — ${dayMonthYear(strings, end)}';
  }

  static String capturedAt(AppStrings strings, DateTime time) {
    return '${dayMonthYear(strings, time)} · ${_time(strings, time)}';
  }

  static String timeOfDay(
    AppStrings strings, {
    required int hour,
    required int minute,
  }) {
    return _time(strings, DateTime(2000, 1, 1, hour, minute));
  }

  /// Short relative age, used on list cards.
  static String relative(AppStrings strings, DateTime time, {DateTime? now}) {
    final difference = (now ?? DateTime.now()).difference(time);
    if (difference.inMinutes < 60) {
      return strings.minutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) return strings.hoursAgo(difference.inHours);
    return strings.daysAgo(difference.inDays);
  }

  static String _month(AppStrings strings, DateTime time) =>
      strings.monthsShort[time.month - 1];

  static String _time(AppStrings strings, DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? strings.timePm : strings.timeAm;
    return '$hour:$minute $period';
  }
}
