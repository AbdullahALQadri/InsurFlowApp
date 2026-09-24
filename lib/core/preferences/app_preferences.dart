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
    this.hasCompletedOnboarding = false,
    this.isLoaded = false,
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

  /// True once the user has finished or skipped onboarding.
  ///
  /// Persisted with the other preferences, so it survives an app close,
  /// a restart and a device reboot. It is deliberately **not** cleared
  /// on sign-out — onboarding explains the product, not the session —
  /// and it disappears only on uninstall, which is what makes a fresh
  /// install show onboarding again.
  final bool hasCompletedOnboarding;

  /// False until the stored preferences have been read.
  ///
  /// Callers that branch on a preference — the splash deciding whether
  /// to show onboarding — must wait for this, or they would act on
  /// defaults and show onboarding to a returning user.
  final bool isLoaded;

  Color? get accent => accentValue == null ? null : Color(accentValue!);

  bool get usesCustomAccent => accentValue != null;

  AppPreferences copyWith({
    String? localeCode,
    ThemeMode? themeMode,
    int? accentValue,
    bool? hasCompletedOnboarding,
    bool? isLoaded,
    bool clearLocale = false,
    bool clearAccent = false,
  }) {
    return AppPreferences(
      localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
      themeMode: themeMode ?? this.themeMode,
      accentValue: clearAccent ? null : (accentValue ?? this.accentValue),
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  Map<String, dynamic> toJson() => {
    if (localeCode != null) 'localeCode': localeCode,
    'themeMode': themeMode.name,
    if (accentValue != null) 'accentValue': accentValue,
    'hasCompletedOnboarding': hasCompletedOnboarding,
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
      // Anything other than an explicit true means onboarding has not
      // been completed, so a corrupt value shows it rather than
      // silently skipping it.
      hasCompletedOnboarding: json['hasCompletedOnboarding'] == true,
      isLoaded: true,
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
      // Nothing stored yet is still a completed read.
      if (raw == null || raw.isEmpty) {
        return const AppPreferences(isLoaded: true);
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AppPreferences(isLoaded: true);
      return AppPreferences.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      // Unreadable preferences must never block startup.
      return const AppPreferences(isLoaded: true);
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
  InMemoryAppPreferencesStore([
    this._preferences = const AppPreferences(isLoaded: true),
  ]);

  AppPreferences _preferences;

  @override
  Future<AppPreferences> read() async => _preferences;

  @override
  Future<void> write(AppPreferences preferences) async =>
      _preferences = preferences;
}
