import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

/// Matches LaTeX math delimited by `\[...\]`, `\(...\)` or `$$...$$` and
/// turns it into a `math` element so [LatexElementBuilder] can render it
/// with an actual typesetter instead of the raw LaTeX source. A bare
/// single-`$` delimiter is intentionally not supported: this app's AI
/// responses quote currency amounts inline (e.g. "$100"), which would
/// otherwise be misparsed as math.
class LatexInlineSyntax extends md.InlineSyntax {
  LatexInlineSyntax()
      : super(r'\\\[([\s\S]+?)\\\]|\\\(([\s\S]+?)\\\)|\$\$([\s\S]+?)\$\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final isDisplay = match.group(1) != null || match.group(3) != null;
    final latex = (match.group(1) ?? match.group(2) ?? match.group(3) ?? '').trim();
    final element = md.Element.text('math', latex);
    element.attributes['display'] = isDisplay ? 'block' : 'inline';
    parser.addNode(element);
    return true;
  }
}

class LatexElementBuilder extends MarkdownElementBuilder {
  LatexElementBuilder({this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (element.tag != 'math') return null;

    final latex = element.textContent;
    final isDisplay = element.attributes['display'] == 'block';
    final style = textStyle ?? preferredStyle ?? parentStyle;

    return Math.tex(
      latex,
      mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
      textStyle: style,
      onErrorFallback: (error) => Text(
        isDisplay ? '\\[$latex\\]' : '\\($latex\\)',
        style: style,
      ),
    );
  }
}
