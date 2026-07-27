import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Light/dark/system theme mode, toggleable from anywhere in the app.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// High-contrast mode, orthogonal to light/dark (design system §2.3, §12).
final highContrastProvider = StateProvider<bool>((ref) => false);

/// App locale — Arabic drives RTL, English drives LTR (design system §1.5).
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
