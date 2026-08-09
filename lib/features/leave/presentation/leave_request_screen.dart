import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/leave_submission_provider.dart';
import '../domain/leave_request_model.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  LeaveType _selectedLeaveType = LeaveType.annual;
  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachment;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
        
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
      });
    }
  }

  void _submit() async {
    final t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorRequiredField)),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorEndDateBeforeStartDate)),
      );
      return;
    }

    if (_selectedLeaveType == LeaveType.sick && _attachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorAttachmentRequired)),
      );
      return;
    }

    final request = LeaveRequestSubmission(
      leaveType: _selectedLeaveType,
      startDate: _startDate!,
      endDate: _endDate!,
      reason: _reasonController.text.trim(),
      attachment: _attachment,
    );

    final success = await ref
        .read(leaveSubmissionProvider.notifier)
        .submitRequest(request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.successLeaveSubmitted)),
      );
      Navigator.of(context).pop();
    }
  }

  String _getLeaveTypeName(LeaveType type, AppLocalizations t) {
    switch (type) {
      case LeaveType.annual:
        return t.leaveTypeAnnual;
      case LeaveType.sick:
        return t.leaveTypeSick;
      case LeaveType.unpaid:
        return t.leaveTypeUnpaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final submissionState = ref.watch(leaveSubmissionProvider);
    final isLoading = submissionState is AsyncLoading;

    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.leaveRequestTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (submissionState is AsyncError) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: colors.errorBg,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 20, color: colors.errorFg),
                        const SizedBox(width: AppSpacing.s2),
                        Expanded(
                          child: Text(
                            t.loginGenericError, // Reusing generic error or could add specific API error text
                            style: textTheme.bodyMedium?.copyWith(color: colors.errorFg),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                ],
                Text(t.leaveTypeLabel, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.s2),
                DropdownButtonFormField<LeaveType>(
                  initialValue: _selectedLeaveType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderDefault),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderFocus, width: 2),
                    ),
                  ),
                  items: LeaveType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getLeaveTypeName(type, t)),
                    );
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() => _selectedLeaveType = val);
                          }
                        },
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.startDateLabel, style: textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.s2),
                          InkWell(
                            onTap: isLoading ? null : () => _pickDate(context, true),
                            borderRadius: AppRadius.smRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s3, vertical: AppSpacing.s3),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.borderDefault),
                                borderRadius: AppRadius.smRadius,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startDate != null
                                        ? dateFormat.format(_startDate!)
                                        : t.selectDateHint,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _startDate != null ? colors.textPrimary : colors.textSecondary,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today, size: 20, color: colors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.endDateLabel, style: textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.s2),
                          InkWell(
                            onTap: isLoading ? null : () => _pickDate(context, false),
                            borderRadius: AppRadius.smRadius,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s3, vertical: AppSpacing.s3),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.borderDefault),
                                borderRadius: AppRadius.smRadius,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endDate != null
                                        ? dateFormat.format(_endDate!)
                                        : t.selectDateHint,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _endDate != null ? colors.textPrimary : colors.textSecondary,
                                    ),
                                  ),
                                  Icon(Icons.calendar_today, size: 20, color: colors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(t.reasonLabel, style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.s2),
                TextFormField(
                  controller: _reasonController,
                  enabled: !isLoading,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: t.reasonHint,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderDefault),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderDefault),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.smRadius,
                      borderSide: BorderSide(color: colors.borderFocus, width: 2),
                    ),
                  ),
                ),
                if (_selectedLeaveType == LeaveType.sick) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(t.attachmentLabel, style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.s2),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _pickFile,
                        style: AppButtonStyles.secondary(context),
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: Text(t.pickFileButton),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Text(
                          _attachment != null ? _attachment!.path.split('/').last : t.attachmentRequiredHint,
                          style: textTheme.bodySmall?.copyWith(
                            color: _attachment != null ? colors.textPrimary : colors.errorFg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                      : Text(t.submitButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
