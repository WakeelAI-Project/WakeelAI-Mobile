import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/leave_request.dart';
import '../data/leave_api_client.dart';

final leaveStatusFilterProvider = StateProvider<String>((ref) => 'All');

class LeaveRequestsNotifier extends AutoDisposeAsyncNotifier<List<LeaveRequest>> {
  @override
  Future<List<LeaveRequest>> build() async {
    final status = ref.watch(leaveStatusFilterProvider);
    final client = ref.watch(leaveApiClientProvider);
    return await client.getLeaveRequests(status: status);
  }


  Future<void> submitDraft(String id) async {
    final client = ref.read(leaveApiClientProvider);
    await client.submitDraft(id);
    ref.invalidateSelf();
  }

  Future<void> cancelDraft(String id) async {
    final client = ref.read(leaveApiClientProvider);
    await client.cancelDraft(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final leaveRequestsProvider = AutoDisposeAsyncNotifierProvider<LeaveRequestsNotifier, List<LeaveRequest>>(() {
  return LeaveRequestsNotifier();
});
