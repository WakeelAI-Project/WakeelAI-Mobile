import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// GitHub's release notes carry a machine-readable `versionCode: N` line
/// (written by release.yml alongside the human-readable notes) since the
/// release itself is always tagged `latest` — there's no version-numbered
/// tag to compare against otherwise.
final _versionCodePattern = RegExp(r'versionCode:\s*(\d+)');

/// Extracts the `versionCode: N` line release.yml writes into the GitHub
/// Release's notes. Returns null if the notes don't contain one (e.g. a
/// release published by hand, or the API response shape changed).
int? parseVersionCodeFromReleaseNotes(String? releaseNotes) {
  if (releaseNotes == null) return null;
  final match = _versionCodePattern.firstMatch(releaseNotes);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

/// Public, no-login-required download link published by release.yml —
/// always resolves to whatever was most recently released under the fixed
/// `latest` tag.
const String updateDownloadUrl =
    'https://github.com/WakeelAI-Project/WakeelAI-Mobile/releases/latest/download/WakeelAI.apk';

const String _latestReleaseApiUrl =
    'https://api.github.com/repos/WakeelAI-Project/WakeelAI-Mobile/releases/latest';

/// Checks GitHub for the versionCode of the latest published release.
///
/// Deliberately uses a bare [Dio] rather than the app's configured client:
/// this hits api.github.com, not the Wakeel backend, so it must not carry
/// the backend's base URL or JWT auth interceptor.
class UpdateCheckerService {
  UpdateCheckerService(this._dio);

  final Dio _dio;

  /// Returns the latest release's versionCode, or null on any failure
  /// (offline, GitHub rate-limited, malformed notes, etc.) — checking for
  /// updates must never be able to break app startup.
  ///
  /// Every failure is logged via [debugPrint] (visible in `flutter logs`/
  /// `adb logcat`) rather than swallowed outright — api.github.com is
  /// unauthenticated here and rate-limited to 60 req/hour per IP, so a
  /// silent null is otherwise indistinguishable from "already up to date".
  Future<int?> fetchLatestVersionCode() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _latestReleaseApiUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final versionCode = parseVersionCodeFromReleaseNotes(response.data?['body'] as String?);
      if (versionCode == null) {
        debugPrint('UpdateCheckerService: latest release notes had no parseable versionCode.');
      }
      return versionCode;
    } on DioException catch (e) {
      debugPrint(
        'UpdateCheckerService: check failed (${e.response?.statusCode ?? e.type}) — ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('UpdateCheckerService: check failed — $e');
      return null;
    }
  }
}
