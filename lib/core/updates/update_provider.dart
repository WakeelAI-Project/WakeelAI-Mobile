import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/app_settings_providers.dart';
import 'update_checker_service.dart';

const _dismissedVersionCodePrefsKey = 'dismissedUpdateVersionCode';

final _updateCheckDioProvider = Provider<Dio>((ref) => Dio());

final _updateCheckerServiceProvider = Provider<UpdateCheckerService>((ref) {
  return UpdateCheckerService(ref.watch(_updateCheckDioProvider));
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// The latest release's versionCode if it's newer than the running app's
/// AND the user hasn't already dismissed that exact version — null
/// otherwise (up to date, dismissed, or the check failed).
///
/// autoDispose so a fresh check runs on the next cold start rather than
/// being cached for the lifetime of the app.
final updateAvailableVersionCodeProvider = FutureProvider.autoDispose<int?>((ref) async {
  final remoteVersionCode = await ref.watch(_updateCheckerServiceProvider).fetchLatestVersionCode();
  if (remoteVersionCode == null) return null;

  final packageInfo = await ref.watch(packageInfoProvider.future);
  final localVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
  if (remoteVersionCode <= localVersionCode) return null;

  final prefs = ref.watch(sharedPreferencesProvider);
  final dismissedVersionCode = prefs.getInt(_dismissedVersionCodePrefsKey);
  if (remoteVersionCode == dismissedVersionCode) return null;

  return remoteVersionCode;
});

/// Remembers that the user dismissed this specific version's update prompt,
/// so it won't nag again until a *newer* version is published.
Future<void> dismissUpdate(WidgetRef ref, int versionCode) async {
  await ref.read(sharedPreferencesProvider).setInt(_dismissedVersionCodePrefsKey, versionCode);
}
