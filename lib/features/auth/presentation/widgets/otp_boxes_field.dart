import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// A row of single-digit boxes for entering a numeric code, auto-advancing
/// focus as each digit is typed (and back on backspace into an empty box).
class OtpBoxesField extends StatefulWidget {
  const OtpBoxesField({
    super.key,
    required this.length,
    required this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool autofocus;

  @override
  State<OtpBoxesField> createState() => OtpBoxesFieldState();
}

class OtpBoxesFieldState extends State<OtpBoxesField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Clears every box and returns focus to the first one — used after a
  /// failed verification so the user can retype the code.
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    widget.onChanged('');
    if (mounted && widget.enabled) _focusNodes.first.requestFocus();
  }

  void _emitCode() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      // Handles a paste of multiple digits into one box: keep the last
      // character here and let the rest fall through as if freshly typed.
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      value = _controllers[index].text;
    }
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == widget.length - 1) {
      _focusNodes[index].unfocus();
    }
    _emitCode();
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _emitCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 44,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
            onKeyEvent: (event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                _handleBackspace(index);
              }
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              autofocus: widget.autofocus && index == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 1,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              onChanged: (value) => _handleChanged(index, value),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smRadius,
                  borderSide: BorderSide(color: colors.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smRadius,
                  borderSide: BorderSide(color: colors.borderFocus, width: 2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smRadius,
                  borderSide: BorderSide(color: colors.borderDefault.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
