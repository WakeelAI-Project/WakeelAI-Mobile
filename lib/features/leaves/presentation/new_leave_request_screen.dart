import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../application/leave_draft_creation_controller.dart';
import '../domain/leave_request_exceptions.dart';
import '../domain/leave_type.dart';

const _maxAttachmentBytes = 10 * 1024 * 1024;
const _allowedAttachmentExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

/// `POST /api/leave-requests` (multipart, attachment inline — see
/// `LeaveApiClient.createLeaveRequest`). Submits directly to the standalone
/// creation flow; the AI-chat-driven path (Story E5b) creates drafts
/// server-side instead and isn't built yet (blocked on the Chat feature).
class NewLeaveRequestScreen extends ConsumerStatefulWidget {
  const NewLeaveRequestScreen({super.key});

  @override
  ConsumerState<NewLeaveRequestScreen> createState() => _NewLeaveRequestScreenState();
}

class _NewLeaveRequestScreenState extends ConsumerState<NewLeaveRequestScreen> {
  final _reasonController = TextEditingController();

  LeaveType _selectedLeaveType = LeaveType.annual;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachment;

  String? _dateRangeError;
  String? _attachmentError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;

    setState(() {
      _dateRangeError = null;
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickAttachment() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _allowedAttachmentExtensions,
    );
    final path = picked?.path;
    if (path == null || !mounted) return;

    final file = File(path);
    final t = AppLocalizations.of(context)!;
    if (await file.length() > _maxAttachmentBytes) {
      if (!mounted) return;
      setState(() {
        _attachment = null;
        _attachmentError = t.newLeaveRequestErrorAttachmentTooLarge;
      });
      return;
    }

    setState(() {
      _attachment = file;
      _attachmentError = null;
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;

    setState(() {
      _dateRangeError = null;
      _attachmentError = null;
    });

    if (_startDate == null || _endDate == null) {
      setState(() => _dateRangeError = t.newLeaveRequestErrorRequiredDates);
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(() => _dateRangeError = t.newLeaveRequestErrorEndBeforeStart);
      return;
    }
    if (_selectedLeaveType == LeaveType.sick && _attachment == null) {
      setState(() => _attachmentError = t.newLeaveRequestErrorAttachmentRequired);
      return;
    }

    final reason = _reasonController.text.trim();
    final result = await ref.read(leaveDraftCreationControllerProvider.notifier).submit(
          leaveType: _selectedLeaveType,
          startDate: _startDate!,
          endDate: _endDate!,
          reason: reason.isEmpty ? null : reason,
          attachment: _attachment,
        );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.newLeaveRequestSuccessMessage)),
      );
      context.pop(true);
    }
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is LeaveDraftCreationException) {
      switch (error.reason) {
        case LeaveDraftCreationFailureReason.validationError:
          return t.newLeaveRequestErrorValidation;
        case LeaveDraftCreationFailureReason.insufficientBalance:
          return t.newLeaveRequestErrorInsufficientBalance;
        case LeaveDraftCreationFailureReason.attachmentRequired:
          return t.newLeaveRequestErrorAttachmentRequired;
        case LeaveDraftCreationFailureReason.unknown:
          return t.newLeaveRequestErrorGeneric;
      }
    }
    return t.newLeaveRequestErrorGeneric;
  }

  InputBorder _fieldBorder(AppColors colors, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.smRadius,
      borderSide: BorderSide(color: focused ? colors.borderFocus : colors.borderDefault, width: focused ? 2 : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;
    final isArabic = t.localeName == 'ar';
    final locale = isArabic ? 'ar' : 'en';
    final dateFormat = DateFormat.yMMMEd(locale);

    final creationState = ref.watch(leaveDraftCreationControllerProvider);
    final isLoading = creationState.isLoading;

    final daysRequested =
        (_startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!))
            ? _endDate!.difference(_startDate!).inDays + 1
            : null;

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          t.newLeaveRequestTitle,
          style: AppTypography.textXl(isArabic).copyWith(color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (creationState.hasError) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  decoration: BoxDecoration(color: colors.errorBg, borderRadius: AppRadius.mdRadius),
                  child: Row(
                    children: [
                      Icon(Symbols.error, size: 20, color: colors.errorFg),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: Text(
                          _errorMessage(t, creationState.error),
                          style: AppTypography.textSm(isArabic).copyWith(color: colors.errorFg),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
              ],
              Text(
                t.newLeaveRequestTypeLabel,
                style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s2),
              DropdownButtonFormField<LeaveType>(
                initialValue: _selectedLeaveType,
                decoration: InputDecoration(border: _fieldBorder(colors), enabledBorder: _fieldBorder(colors)),
                items: LeaveType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.label(t))))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) setState(() => _selectedLeaveType = value);
                      },
              ),
              const SizedBox(height: AppSpacing.s4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DateField(
                      label: t.newLeaveRequestStartDateLabel,
                      hint: t.newLeaveRequestSelectDateHint,
                      value: _startDate,
                      dateFormat: dateFormat,
                      isArabic: isArabic,
                      colors: colors,
                      enabled: !isLoading,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Expanded(
                    child: _DateField(
                      label: t.newLeaveRequestEndDateLabel,
                      hint: t.newLeaveRequestSelectDateHint,
                      value: _endDate,
                      dateFormat: dateFormat,
                      isArabic: isArabic,
                      colors: colors,
                      enabled: !isLoading,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              if (_dateRangeError != null) ...[
                const SizedBox(height: AppSpacing.s2),
                Text(_dateRangeError!, style: AppTypography.textXs(isArabic).copyWith(color: colors.errorFg)),
              ],
              if (daysRequested != null) ...[
                const SizedBox(height: AppSpacing.s2),
                Text(
                  t.newLeaveRequestDaysSummary(daysRequested),
                  style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.s4),
              Text(
                t.newLeaveRequestReasonLabel,
                style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _reasonController,
                enabled: !isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: t.newLeaveRequestReasonHint,
                  border: _fieldBorder(colors),
                  enabledBorder: _fieldBorder(colors),
                  focusedBorder: _fieldBorder(colors, focused: true),
                ),
              ),
              if (_selectedLeaveType == LeaveType.sick) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  t.newLeaveRequestAttachmentLabel,
                  style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.s2),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _pickAttachment,
                      style: AppButtonStyles.secondary(context),
                      icon: const Icon(Symbols.attach_file, size: 18),
                      label: Text(t.newLeaveRequestAttachmentButton, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Text(
                        _attachment != null ? _attachment!.uri.pathSegments.last : t.newLeaveRequestAttachmentRequiredHint,
                        style: AppTypography.textSm(isArabic).copyWith(
                              color: _attachment != null ? colors.textPrimary : colors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_attachmentError != null) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(_attachmentError!, style: AppTypography.textXs(isArabic).copyWith(color: colors.errorFg)),
                ],
              ],
              const SizedBox(height: AppSpacing.s8),
              ElevatedButton(
                style: AppButtonStyles.primary(context),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                      )
                    : Text(t.newLeaveRequestSubmitButton, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.hint,
    required this.value,
    required this.dateFormat,
    required this.isArabic,
    required this.colors,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final DateFormat dateFormat;
  final bool isArabic;
  final AppColors colors;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.textSm(isArabic).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.s2),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppRadius.smRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s3),
            decoration: BoxDecoration(
              border: Border.all(color: colors.borderDefault),
              borderRadius: AppRadius.smRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value != null ? dateFormat.format(value!) : hint,
                    style: AppTypography.textSm(isArabic).copyWith(
                          color: value != null ? colors.textPrimary : colors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Symbols.calendar_today, size: 18, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
