import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wakeel_ai_app/features/leaves/data/leave_api_client.dart';
import 'package:wakeel_ai_app/features/leaves/domain/leave_type.dart';

/// Captures the `FormData` a request was sent with instead of making a real
/// HTTP call, and always answers with a canned success body.
class _CapturingAdapter implements HttpClientAdapter {
  FormData? capturedData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedData = options.data as FormData?;
    return ResponseBody.fromString(
      '{"url": "/uploads/attachment", "request_id": "req-1", "status": "Draft", "days_requested": 1}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Writes [bytes] to a temp file with no extension — reproducing what
/// `file_picker` frequently hands back on Android (a cached copy of a
/// content:// pick with no extension at all), which is what made
/// filename-based content-type detection unreliable on-device.
File _extensionlessFile(String bytesLabel, List<int> bytes) {
  final file = File('${Directory.systemTemp.path}/attachment_test_$bytesLabel');
  file.writeAsBytesSync(bytes);
  return file;
}

/// Best-effort cleanup: on Windows, dio's own multipart file stream may not
/// have released its handle on the file yet by the time the test finishes,
/// which is unrelated to what's under test here.
void _tryDelete(File file) {
  try {
    file.deleteSync();
  } catch (_) {}
}

const _pngMagicBytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00];
const _pdfMagicBytes = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34];

void main() {
  late _CapturingAdapter adapter;
  late DioLeaveApiClient client;

  setUp(() {
    adapter = _CapturingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter;
    client = DioLeaveApiClient(dio);
  });

  group('uploadAttachment', () {
    test('sends image/png for an extensionless file with PNG magic bytes', () async {
      final file = _extensionlessFile('png', _pngMagicBytes);
      addTearDown(() => _tryDelete(file));

      await client.uploadAttachment(file);

      final uploaded = adapter.capturedData!.files.single.value;
      expect(uploaded.contentType?.mimeType, 'image/png');
    });

    test('sends application/pdf for an extensionless file with PDF magic bytes', () async {
      final file = _extensionlessFile('pdf', _pdfMagicBytes);
      addTearDown(() => _tryDelete(file));

      await client.uploadAttachment(file);

      final uploaded = adapter.capturedData!.files.single.value;
      expect(uploaded.contentType?.mimeType, 'application/pdf');
    });
  });

  group('createLeaveRequest', () {
    test('sends image/jpeg for an extensionless file with JPEG magic bytes', () async {
      final file = _extensionlessFile('jpg', const [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);
      addTearDown(() => _tryDelete(file));

      await client.createLeaveRequest(
        leaveType: LeaveType.sick,
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 12, 2),
        attachment: file,
      );

      final uploaded = adapter.capturedData!.files.single.value;
      expect(uploaded.contentType?.mimeType, 'image/jpeg');
    });
  });
}
