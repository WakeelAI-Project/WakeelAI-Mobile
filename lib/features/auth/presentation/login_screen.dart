import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/seal_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/login_controller.dart';
import '../domain/auth_exceptions.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final t = AppLocalizations.of(context)!;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return t.loginErrorEmailRequired;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return t.loginErrorEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return t.loginErrorPasswordRequired;
    if (value.length < 6) return t.loginErrorPasswordTooShort;
    return null;
  }

  void _submit(bool isLoading) {
    if (isLoading) return;
    if (_formKey.currentState?.validate() != true) return;
    ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is LoginFailure) {
      switch (error.reason) {
        case LoginFailureReason.invalidCredentials:
          return t.loginInvalidCredentials;
        case LoginFailureReason.accountInactive:
          return t.loginAccountInactive;
        case LoginFailureReason.unknown:
          return t.loginGenericError;
      }
    }
    return t.loginGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: SealMark.logomark(size: 56, ringColor: colors.brandPrimary)),
                    const SizedBox(height: AppSpacing.s4),
                    Text(t.appName, textAlign: TextAlign.center, style: textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      t.appTagline,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (loginState.hasError) ...[
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
                                _errorMessage(t, loginState.error),
                                style: textTheme.bodyMedium?.copyWith(color: colors.errorFg),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                    ],
                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        labelText: t.loginEmailLabel,
                        hintText: t.loginEmailHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(isLoading),
                      decoration: InputDecoration(
                        labelText: t.loginPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          tooltip: _obscurePassword ? t.loginShowPassword : t.loginHidePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    ElevatedButton(
                      style: AppButtonStyles.primary(context),
                      // Stays non-null so the button keeps its primary
                      // (enabled) colors while loading, instead of Flutter's
                      // disabled style — _submit() itself no-ops if a
                      // request is already in flight.
                      onPressed: () => _submit(isLoading),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                            )
                          : Text(t.loginSubmit),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
