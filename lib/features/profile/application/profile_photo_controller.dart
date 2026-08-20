import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/employee_provider.dart';
import '../../home/data/employee_api_client.dart';

final profilePhotoControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfilePhotoController, void>(
  ProfilePhotoController.new,
);

/// Drives the profile-photo upload/remove flow — refetches
/// [employeeProfileProvider] on success so the avatar updates everywhere
/// it's shown.
class ProfilePhotoController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> uploadPhoto(File file) async {
    state = const AsyncLoading();
    var succeeded = false;
    state = await AsyncValue.guard(() async {
      await ref.read(employeeApiClientProvider).uploadPhoto(file);
      succeeded = true;
    });
    if (succeeded) ref.invalidate(employeeProfileProvider);
    return succeeded;
  }

  Future<bool> removePhoto() async {
    state = const AsyncLoading();
    var succeeded = false;
    state = await AsyncValue.guard(() async {
      await ref.read(employeeApiClientProvider).removePhoto();
      succeeded = true;
    });
    if (succeeded) ref.invalidate(employeeProfileProvider);
    return succeeded;
  }
}
