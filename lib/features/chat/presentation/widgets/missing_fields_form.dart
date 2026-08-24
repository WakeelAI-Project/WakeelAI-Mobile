import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../domain/chat_missing_field.dart';
import '../../../leaves/application/leave_request_service.dart';

class MissingFieldsForm extends ConsumerStatefulWidget {
  const MissingFieldsForm({
    super.key,
    required this.fields,
    required this.onSubmit,
  });

  final List<ChatMissingField> fields;
  final Future<void> Function(Map<String, dynamic>) onSubmit;

  @override
  ConsumerState<MissingFieldsForm> createState() => _MissingFieldsFormState();
}

class _MissingFieldsFormState extends ConsumerState<MissingFieldsForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (var f in widget.fields) {
      if (f.type == 'dropdown' && f.options != null && f.options!.isNotEmpty) {
        _values[f.name] = f.options!.first;
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final processedValues = <String, dynamic>{};
      
      for (var f in widget.fields) {
        final val = _values[f.name];
        if (val == null && f.required) {
          throw Exception('Missing required field: ${f.label}');
        }
        
        if (f.type == 'file' && val is File) {
          final url = await ref.read(leaveRequestServiceProvider).uploadLeaveAttachment(val);
          processedValues[f.name] = url;
        } else if (f.type == 'date' && val is DateTime) {
          processedValues[f.name] = AppDateFormat.toApi(val);
        } else {
          processedValues[f.name] = val;
        }
      }

      await widget.onSubmit(processedValues);
    } catch (e) {
      setState(() {
        _error = 'Failed to process input. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide more details:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildField(f, colors),
            )),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error!, style: TextStyle(color: Colors.red[800])),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(ChatMissingField field, AppColors colors) {
    switch (field.type) {
      case 'dropdown':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          initialValue: _values[field.name],
          items: (field.options ?? []).map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setState(() => _values[field.name] = v),
          onSaved: (v) => _values[field.name] = v,
        );
      case 'date':
        final isStartDate = field.name.toLowerCase().contains('start');
        final isEndDate = field.name.toLowerCase().contains('end');
        
        final now = DateTime.now();
        DateTime minDate = DateTime(now.year, now.month, 1);
        DateTime maxDate = DateTime(now.year, 12, 31);
        DateTime? defaultInitialDate;

        if (isEndDate) {
          DateTime? start;
          for (var entry in _values.entries) {
            if (entry.key.toLowerCase().contains('start') && entry.value is DateTime) {
              start = entry.value as DateTime;
              break;
            }
          }
          if (start != null) {
            if (start.isAfter(minDate)) {
              minDate = start;
            }
            defaultInitialDate = start;
          }
        }

        return _DateSelector(
          label: field.label,
          initialDate: _values[field.name] as DateTime?,
          defaultInitialDate: defaultInitialDate,
          firstDate: minDate,
          lastDate: maxDate,
          onChanged: (d) {
            setState(() {
              _values[field.name] = d;
              if (isStartDate && d != null) {
                for (var key in _values.keys.toList()) {
                  if (key.toLowerCase().contains('end')) {
                    final end = _values[key];
                    if (end is DateTime && end.isBefore(d)) {
                      _values[key] = null;
                    }
                  }
                }
              }
            });
          },
        );
      case 'file':
        return _FileSelector(
          label: field.label,
          selectedFile: _values[field.name] as File?,
          onChanged: (f) => setState(() => _values[field.name] = f),
        );
      case 'number':
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => (field.required && (v == null || v.isEmpty)) ? 'Required' : null,
          onSaved: (v) {
            if (v != null && v.isNotEmpty) {
              _values[field.name] = num.tryParse(v);
            }
          },
        );
      case 'text':
      default:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) => (field.required && (v == null || v.trim().isEmpty)) ? 'Required' : null,
          onSaved: (v) => _values[field.name] = v?.trim(),
        );
    }
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label, 
    this.initialDate, 
    this.defaultInitialDate,
    this.firstDate,
    this.lastDate,
    required this.onChanged
  });
  
  final String label;
  final DateTime? initialDate;
  final DateTime? defaultInitialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context)!.localeName == 'ar';
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final d = await showDatePicker(
          context: context,
          initialDate: initialDate ?? defaultInitialDate ?? now,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        if (d != null) onChanged(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          initialDate != null ? AppDateFormat.date(initialDate!, isArabic: isArabic) : 'Select Date',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _FileSelector extends StatelessWidget {
  const _FileSelector({required this.label, this.selectedFile, required this.onChanged});
  
  final String label;
  final File? selectedFile;
  final ValueChanged<File?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await FilePicker.pickFile(type: FileType.any);
        final path = picked?.path;
        if (path != null) {
          onChanged(File(path));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedFile != null ? selectedFile!.path.split(Platform.pathSeparator).last : 'Select File',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
