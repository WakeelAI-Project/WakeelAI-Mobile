import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final modeString = ref.watch(sharedPreferencesProvider).getString('themeMode');
    if (modeString == 'light') return ThemeMode.light;
    if (modeString == 'dark') return ThemeMode.dark;
    // No explicit choice yet — match the device's theme. Settings has a
    // System card so this now shows as selected instead of blank.
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    ref.read(sharedPreferencesProvider).setString('themeMode', mode.name);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class HighContrastNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool('highContrast') ?? false;
  }

  void setHighContrast(bool value) {
    ref.read(sharedPreferencesProvider).setBool('highContrast', value);
    state = value;
  }
}

final highContrastProvider = NotifierProvider<HighContrastNotifier, bool>(HighContrastNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final languageCode = ref.watch(sharedPreferencesProvider).getString('locale') ?? 'en';
    return Locale(languageCode);
  }

  void setLocale(Locale newLocale) {
    ref.read(sharedPreferencesProvider).setString('locale', newLocale.languageCode);
    state = newLocale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
