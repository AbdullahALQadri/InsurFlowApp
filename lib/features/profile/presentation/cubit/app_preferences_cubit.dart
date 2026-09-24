import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurflow/core/preferences/app_preferences.dart';

/// Holds the language and theme the app is currently running with, and
/// persists every change so it survives a restart.
class AppPreferencesCubit extends Cubit<AppPreferences> {
  AppPreferencesCubit({required AppPreferencesStore store})
    : _store = store,
      super(const AppPreferences());

  final AppPreferencesStore _store;

  Future<void> load() async => emit(await _store.read());

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    final updated = state.copyWith(themeMode: mode);
    emit(updated);
    await _store.write(updated);
  }

  /// A null [accent] restores the default brand colour; any other
  /// value switches the app to the custom theme, in whichever
  /// brightness [AppPreferences.themeMode] currently selects.
  Future<void> setAccent(Color? accent) async {
    final value = accent?.toARGB32();
    if (value == state.accentValue) return;
    final updated = value == null
        ? state.copyWith(clearAccent: true)
        : state.copyWith(accentValue: value);
    emit(updated);
    await _store.write(updated);
  }

  /// A null [localeCode] follows the device language.
  Future<void> setLocale(String? localeCode) async {
    if (localeCode == state.localeCode) return;
    final updated = localeCode == null
        ? state.copyWith(clearLocale: true)
        : state.copyWith(localeCode: localeCode);
    emit(updated);
    await _store.write(updated);
  }
}
