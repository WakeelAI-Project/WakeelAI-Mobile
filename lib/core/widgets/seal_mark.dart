import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Wakeel AI signature seal mark (design system §9).
///
/// Used in exactly one place, by design: the inline [citation] marker next
/// to every AI legal citation (e.g. "Article 84 · Labor Law 14/2025"). Do
/// not reuse it elsewhere — its meaning as "this claim is stamped/
/// verifiable" depends on scarcity. For the app's logo, see [BrandMark].
class SealMark extends StatelessWidget {
  const SealMark({super.key, this.size = 40, this.ringColor, this.innerColor});

  /// Sized for an inline citation marker, next to citation text.
  const SealMark.citation({super.key, this.size = 16, this.ringColor, this.innerColor});

  final double size;
  final Color? ringColor;
  final Color? innerColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return CustomPaint(
      size: Size.square(size),
      painter: _SealMarkPainter(
        ringColor: ringColor ?? colors.textOnNavy,
        innerColor: innerColor ?? colors.accent,
      ),
    );
  }
}

class _SealMarkPainter extends CustomPainter {
  _SealMarkPainter({required this.ringColor, required this.innerColor});

  final Color ringColor;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final outerRing = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.16;
    canvas.drawCircle(center, radius - outerRing.strokeWidth / 2, outerRing);

    final innerRing = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06;
    canvas.drawCircle(center, radius * 0.62, innerRing);

    final innerFill = Paint()..color = innerColor;
    canvas.drawCircle(center, radius * 0.42, innerFill);
  }

  @override
  bool shouldRepaint(covariant _SealMarkPainter oldDelegate) {
    return oldDelegate.ringColor != ringColor || oldDelegate.innerColor != innerColor;
  }
}
