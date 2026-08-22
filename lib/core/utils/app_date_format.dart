import 'package:intl/intl.dart';

/// Single source of truth for date/time formatting — display and wire.
///
/// Display formats ([date], [time]) are locale-aware (English/Arabic) and
/// are the only date/time formatting that should ever reach a screen; no
/// widget should call [DateFormat] directly with its own pattern.
///
/// [toApi] is the one place the `yyyy-MM-dd` wire format (the backend's
/// contract for date fields, e.g. CreateLeaveRequestDto's StartDate/EndDate)
/// is defined. It is deliberately locale-independent — this is a contract
/// with the backend, not a display concern, and must never change to match
/// a display format.
abstract final class AppDateFormat {
  /// A day-level display date, e.g. "Aug 22, 2026" (or the Arabic
  /// equivalent). Used everywhere a date is shown to the user.
  static String date(DateTime value, {required bool isArabic}) {
    return DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(value);
  }

  /// A display time, e.g. "4:12 PM" (or the Arabic equivalent).
  static String time(DateTime value, {required bool isArabic}) {
    return DateFormat.jm(isArabic ? 'ar' : 'en').format(value);
  }

  /// Parses a wire-format date string (as received from the backend, e.g.
  /// `LeaveRequest.startDate`) and formats it for display, falling back to
  /// the raw string if it isn't parseable rather than throwing.
  static String dateFromApi(String value, {required bool isArabic}) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return date(parsed, isArabic: isArabic);
  }

  /// Encodes a [DateTime] into the backend's wire format for date fields.
  static String toApi(DateTime value) => DateFormat('yyyy-MM-dd').format(value);
}
