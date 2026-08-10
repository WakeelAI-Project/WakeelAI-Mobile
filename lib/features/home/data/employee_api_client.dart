import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/employee_profile.dart';
import '../domain/employee_exceptions.dart';

abstract class EmployeeApiClient {
  Future<EmployeeProfile> getEmployeeProfile();
}

class DioEmployeeApiClient implements EmployeeApiClient {
  DioEmployeeApiClient(this._dio);

  final Dio _dio;

  @override
  Future<EmployeeProfile> getEmployeeProfile() async {
    try {
      final response = await _dio.get('/api/employees/me');
      return EmployeeProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw EmployeeFailure(
        _reasonFor(e),
        'Failed to load profile',
      );
    } catch (e) {
      throw EmployeeFailure(
        EmployeeFailureReason.unknown,
        'Unexpected error: $e',
      );
    }
  }

  EmployeeFailureReason _reasonFor(DioException e) {
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      return EmployeeFailureReason.unauthorized;
    }
    if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return EmployeeFailureReason.serverError;
    }
    return EmployeeFailureReason.unknown;
  }
}

final employeeApiClientProvider = Provider<EmployeeApiClient>((ref) {
  return DioEmployeeApiClient(ref.watch(dioClientProvider));
});
