import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/app_settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Profile's hire-date formatting (DateFormat.yMMMd) needs locale symbol
  // data loaded up front — 'ar' isn't in intl's built-in default.
  await initializeDateFormatting();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WakeelApp(),
    ),
  );
}