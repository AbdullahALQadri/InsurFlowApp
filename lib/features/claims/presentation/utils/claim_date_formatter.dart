class ClaimDateFormatter {
  ClaimDateFormatter._();

  static String lastUpdated(DateTime time, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final date = DateTime(time.year, time.month, time.day);
    final clock = _time(time);

    if (date == today) return 'Today, $clock';
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $clock';
    }
    return '${time.day} ${_months[time.month - 1]}, $clock';
  }

  static String assignedOn(DateTime time) {
    return '${time.day} ${_months[time.month - 1]} ${time.year}';
  }

  static String dayMonthYear(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    return '$day ${_months[time.month - 1]} ${time.year}';
  }

  static String dateRange(DateTime start, DateTime end) {
    return '${dayMonthYear(start)} — ${dayMonthYear(end)}';
  }

  static String capturedAt(DateTime time) {
    return '${dayMonthYear(time)} · ${_time(time)}';
  }

  static String timeOfDay({required int hour, required int minute}) {
    return _time(DateTime(2000, 1, 1, hour, minute));
  }

  static String _time(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}
