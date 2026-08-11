import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/employee_api_client.dart';
import '../domain/employee_profile.dart';

final employeeProfileProvider =
    FutureProvider.autoDispose<EmployeeProfile>((ref) async {
  final client = ref.watch(employeeApiClientProvider);
  return client.getEmployeeProfile();
});
