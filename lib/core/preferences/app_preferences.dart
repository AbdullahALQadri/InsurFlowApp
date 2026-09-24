import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Language and theme choices.
///
/// These are device preferences, not backend data: no mobile endpoint
/// stores or returns them. "System" means follow the OS, which is what
/// the app did before these controls existed, so it stays the default.
@immutable
class AppPreferences {
  const AppPreferences({
    this.localeCode,
    this.themeMode = ThemeMode.system,
    this.accentValue,
  });

  /// `en`, `ar`, or null to follow the device language.
  final String? localeCode;

  final ThemeMode themeMode;

  /// ARGB of the user's custom accent, or null to use the brand colour.
  ///
  /// Stored as an int because that is what survives JSON. A non-null
  /// value is what makes the app run the custom theme; light/dark is
  /// still controlled by [themeMode], so a custom accent works in both.
  final int? accentValue;

  Locale? get locale => localeCode == null ? null : Locale(localeCode!);

  bool get followsSystemLanguage => localeCode == null;

  Color? get accent => accentValue == null ? null : Color(accentValue!);

  bool get usesCustomAccent => accentValue != null;

  AppPreferences copyWith({
    String? localeCode,
    ThemeMode? themeMode,
    int? accentValue,
    bool clearLocale = false,
    bool clearAccent = false,
  }) {
    return AppPreferences(
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      themeMode: themeMode ?? this.themeMode,
      accentValue: clearAccent ? null : (accentValue ?? this.accentValue),
    );
  }

  Map<String, dynamic> toJson() => {
    if (localeCode != null) 'localeCode': localeCode,
    'themeMode': themeMode.name,
    if (accentValue != null) 'accentValue': accentValue,
  };

  static AppPreferences fromJson(Map<String, dynamic> json) {
    final code = json['localeCode'];
    final mode = json['themeMode'];
    final accent = json['accentValue'];
    return AppPreferences(
      // Anything other than a supported language falls back to system.
      localeCode: (code == 'en' || code == 'ar') ? code as String : null,
      themeMode: ThemeMode.values.firstWhere(
        (value) => value.name == mode,
        orElse: () => ThemeMode.system,
      ),
      // A malformed accent falls back to the brand colour rather than
      // producing an unreadable theme.
      accentValue: accent is int ? accent : null,
    );
  }
}

abstract class AppPreferencesStore {
  Future<AppPreferences> read();

  Future<void> write(AppPreferences preferences);
}

class SecureAppPreferencesStore implements AppPreferencesStore {
  SecureAppPreferencesStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'insurflow.preferences';

  final FlutterSecureStorage _storage;

  @override
  Future<AppPreferences> read() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return const AppPreferences();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AppPreferences();
      return AppPreferences.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      // Unreadable preferences must never block startup.
      return const AppPreferences();
    }
  }

  @override
  Future<void> write(AppPreferences preferences) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(preferences.toJson()));
    } catch (_) {
      // A failed write only costs persistence, not the current session.
    }
  }
}

class InMemoryAppPreferencesStore implements AppPreferencesStore {
  InMemoryAppPreferencesStore([this._preferences = const AppPreferences()]);

  AppPreferences _preferences;

  @override
  Future<AppPreferences> read() async => _preferences;

  @override
  Future<void> write(AppPreferences preferences) async =>
      _preferences = preferences;
}
