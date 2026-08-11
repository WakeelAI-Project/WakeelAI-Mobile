import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wakeel_ai_app/core/theme/app_colors.dart';
import 'package:wakeel_ai_app/l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to home after animation + brief pause
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    // In case l10n doesn't have it yet, we'll use a fallback, 
    // but we will add 'welcomeGreeting' to l10n.
    final l10n = AppLocalizations.of(context)!;
    
    // We try to use l10n.welcomeGreeting, but if it doesn't exist we'd fail to compile. 
    // We will add it next.

    return Scaffold(
      backgroundColor: colors.bgPage,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              l10n.welcomeGreeting,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colors.brandPrimary,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
