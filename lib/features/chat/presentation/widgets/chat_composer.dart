import 'package:flutter/material.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  final Future<void> Function(String) onSend;
  final bool isLoading;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final empty = _controller.text.trim().isEmpty;
      if (empty != _isEmpty) {
        setState(() {
          _isEmpty = empty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    _controller.clear();
    await widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // --spacing-4
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24), // --radius-2xl
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? colors.borderFocus
                        : colors.borderDefault,
                    width: _focusNode.hasFocus ? 2.0 : 1.0,
                  ),
                  color: colors.bgCard,
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.chatComposerPlaceholder,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                  onTapOutside: (_) => _focusNode.unfocus(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isEmpty || widget.isLoading)
                    ? colors.bgCardRaised
                    : colors.brandPrimary,
              ),
              child: IconButton(
                icon: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.textOnNavy,
                        ),
                      )
                    : Icon(
                        LucideIcons.send,
                        color: (_isEmpty || widget.isLoading)
                            ? colors.textSecondary
                            : colors.textOnNavy,
                      ),
                onPressed: (_isEmpty || widget.isLoading) ? null : _handleSend,
                tooltip: 'Send',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
