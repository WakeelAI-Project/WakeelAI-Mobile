import 'dart:math' as math;
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, required this.dotColor});

  final Color dotColor;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16, // More compact height
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Offset each dot's animation phase
              final double phaseOffset = index * (math.pi / 4);
              // Calculate sine wave: 0 to 1 back to 0
              final double t = (_controller.value * 2 * math.pi) - phaseOffset;
              // Only bounce during the first half of the sine wave to give a "pause" effect
              final double y = math.max(0.0, math.sin(t));
              
              return Transform.translate(
                offset: Offset(0, -4 * y),
                child: Opacity(
                  opacity: 0.3 + (0.7 * y),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: widget.dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}
