import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/leave_repository.dart';
import '../domain/leave_request_model.dart';

final leaveSubmissionProvider =
    StateNotifierProvider.autoDispose<LeaveSubmissionNotifier, AsyncValue<void>>((ref) {
  return LeaveSubmissionNotifier(ref.watch(leaveRepositoryProvider));
});

class LeaveSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final LeaveRepository _repository;

  LeaveSubmissionNotifier(this._repository) : super(const AsyncData(null));

  Future<bool> submitRequest(LeaveRequestSubmission request) async {
    state = const AsyncLoading();
    try {
      await _repository.submitLeaveRequest(request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
