import 'package:wakeel_ai_app/l10n/app_localizations.dart';

/// The three leave types the backend accepts on `POST /api/leave-requests`
/// (`CreateLeaveRequestDto.LeaveType`, validated server-side against
/// `^(Annual|Sick|Unpaid)$`). Distinct from [LeaveRequest.leaveType], which
/// is the free-text value already stored on an existing request.
enum LeaveType {
  annual('Annual'),
  sick('Sick'),
  unpaid('Unpaid');

  final String apiValue;
  const LeaveType(this.apiValue);

  String label(AppLocalizations t) {
    switch (this) {
      case LeaveType.annual:
        return t.leaveTypeAnnual;
      case LeaveType.sick:
        return t.leaveTypeSick;
      case LeaveType.unpaid:
        return t.leaveTypeUnpaid;
    }
  }
}
