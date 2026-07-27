import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the backend API (wakeel-ai-api-documentation.md §Overview).
///
/// Override at build/run time with `--dart-define=API_BASE_URL=...` to
/// point at a locally-run backend during development.
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api.wakeel-ai.com/v1',
);

final dioClientProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});
