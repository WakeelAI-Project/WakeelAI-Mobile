import 'package:flutter_test/flutter_test.dart';
import 'package:wakeel_ai_app/core/updates/update_checker_service.dart';

void main() {
  group('parseVersionCodeFromReleaseNotes', () {
    test('extracts the versionCode from a release.yml-formatted body', () {
      const notes = 'versionCode: 42\nAutomatically updated on every push to main. Commit: abc123';
      expect(parseVersionCodeFromReleaseNotes(notes), 42);
    });

    test('extracts the versionCode regardless of surrounding whitespace', () {
      expect(parseVersionCodeFromReleaseNotes('versionCode:   7'), 7);
    });

    test('returns null when there is no versionCode line', () {
      expect(parseVersionCodeFromReleaseNotes('Manually published release, no notes format.'), isNull);
    });

    test('returns null for null input', () {
      expect(parseVersionCodeFromReleaseNotes(null), isNull);
    });

    test('returns null for an empty string', () {
      expect(parseVersionCodeFromReleaseNotes(''), isNull);
    });
  });
}
