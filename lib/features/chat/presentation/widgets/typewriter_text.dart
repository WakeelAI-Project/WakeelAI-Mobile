import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.onComplete,
    this.isStreaming = false,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback? onComplete;
  final bool isStreaming;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isStreaming) {
      _startTyping();
    } else {
      _displayedText = widget.text;
    }
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && oldWidget.text != widget.text) {
      if (!oldWidget.isStreaming) {
        _currentIndex = 0;
        _displayedText = '';
        _startTyping();
      }
    } else if (!widget.isStreaming) {
      _timer?.cancel();
      _displayedText = widget.text;
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return MarkdownBody(
      data: _displayedText,
      styleSheet: MarkdownStyleSheet(
        p: widget.style,
        strong: widget.style?.copyWith(fontWeight: FontWeight.bold),
        em: widget.style?.copyWith(fontStyle: FontStyle.italic),
        tableBody: widget.style,
        tableHead: widget.style?.copyWith(fontWeight: FontWeight.bold),
        tableBorder: TableBorder.all(
          color: colors.borderDefault,
          width: 1,
        ),
      ),
    );
  }
}
