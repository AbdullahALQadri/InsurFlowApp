class JsonReader {
  JsonReader._();

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }

  static DateTime? date(Map<String, dynamic> json, List<String> keys) {
    final raw = string(json, keys);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  static Map<String, dynamic>? nested(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final mapped = asMap(json[key]);
      if (mapped != null) return mapped;
    }
    return null;
  }

  static List<dynamic> list(dynamic body) {
    if (body is List) return body;
    final map = asMap(body);
    if (map == null) return const [];
    for (final key in ['data', 'items', 'claims', 'results']) {
      final value = map[key];
      if (value is List) return value;
      final nestedMap = asMap(value);
      if (nestedMap == null) continue;
      for (final nestedKey in ['data', 'items', 'claims', 'results']) {
        final nestedValue = nestedMap[nestedKey];
        if (nestedValue is List) return nestedValue;
      }
    }
    return const [];
  }

  static Map<String, dynamic>? object(dynamic body) {
    final map = asMap(body);
    if (map == null) return null;
    for (final key in ['data', 'result', 'claim', 'payload']) {
      final nestedMap = asMap(map[key]);
      if (nestedMap != null) return nestedMap;
    }
    return map;
  }

  static int? integer(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}
