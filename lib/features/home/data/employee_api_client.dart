import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/employee_profile.dart';
import '../domain/employee_exceptions.dart';

abstract class EmployeeApiClient {
  Future<EmployeeProfile> getEmployeeProfile();
  Future<EmployeeProfile> uploadPhoto(File file);
  Future<EmployeeProfile> removePhoto();

  /// `PATCH /api/employees/me/timezone`. Reports the device's current IANA
  /// time zone (e.g. "Africa/Cairo") so date-sensitive calculations on the
  /// backend (currently only CurrentLeave's elapsed-days count) use the
  /// employee's own local day boundary instead of UTC's. Safe to call
  /// unconditionally on every login/app-start — the backend just overwrites
  /// the stored value, so there's nothing to keep in sync locally.
  Future<EmployeeProfile> updateTimeZone(String timeZoneId);
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

  @override
  Future<EmployeeProfile> uploadPhoto(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
      });
      final response = await _dio.post('/api/employees/me/photo', data: formData);
      return EmployeeProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw EmployeeFailure(_reasonFor(e), 'Failed to upload photo');
    } catch (e) {
      throw EmployeeFailure(EmployeeFailureReason.unknown, 'Unexpected error: $e');
    }
  }

  @override
  Future<EmployeeProfile> removePhoto() async {
    try {
      final response = await _dio.delete('/api/employees/me/photo');
      return EmployeeProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw EmployeeFailure(_reasonFor(e), 'Failed to remove photo');
    } catch (e) {
      throw EmployeeFailure(EmployeeFailureReason.unknown, 'Unexpected error: $e');
    }
  }

  @override
  Future<EmployeeProfile> updateTimeZone(String timeZoneId) async {
    try {
      final response = await _dio.patch(
        '/api/employees/me/timezone',
        data: {'timezone_id': timeZoneId},
      );
      return EmployeeProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw EmployeeFailure(_reasonFor(e), 'Failed to update time zone');
    } catch (e) {
      throw EmployeeFailure(EmployeeFailureReason.unknown, 'Unexpected error: $e');
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
