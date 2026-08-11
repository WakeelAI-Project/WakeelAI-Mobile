import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/seal_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/login_controller.dart';
import '../application/pending_password_change_provider.dart';
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _emailDirty = false;
  bool _passwordDirty = false;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _showPasswordChangedBanner = false;

  @override
  void initState() {
    super.initState();
    // One-shot: consume the flag now so revisiting this screen later
    // (e.g. after logout) doesn't keep showing a stale success message.
    // Clearing it is deferred to after this frame — Riverpod disallows
    // writing to a provider during initState.
    if (ref.read(passwordJustChangedProvider)) {
      _showPasswordChangedBanner = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(passwordJustChangedProvider.notifier).state = false;
      });
    }
    _emailFocus.addListener(() {
      setState(() {
        if (_emailFocus.hasFocus) _isSubmitting = false;
        if (!_emailFocus.hasFocus) _emailTouched = true;
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
        if (_passwordFocus.hasFocus) _isSubmitting = false;
        if (!_passwordFocus.hasFocus) _passwordTouched = true;
      });
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (_emailFocus.hasFocus && !_isSubmitting) return null;
    if (!_emailTouched && !_isSubmitting) return null;
    if (!_emailDirty && !_isSubmitting) return null;
    
    final t = AppLocalizations.of(context)!;
    final email = value?.trim() ?? '';
    if (email.isEmpty) return t.loginErrorEmailRequired;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return t.loginErrorEmailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    if (_passwordFocus.hasFocus && !_isSubmitting) return null;
    if (!_passwordTouched && !_isSubmitting) return null;
    if (!_passwordDirty && !_isSubmitting) return null;

    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return t.loginErrorPasswordRequired;
    if (value.length < 6) return t.loginErrorPasswordTooShort;
    return null;
  }

  void _submit(bool isLoading) {
    if (isLoading) return;
    setState(() => _isSubmitting = true);
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
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            iconSize: 28,
            tooltip: t.settingsTitle,
            onPressed: () => context.push('/settings'),
            icon: Icon(Symbols.settings, color: colors.textSecondary, fill: 0),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
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
                    if (_showPasswordChangedBanner) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s3),
                        decoration: BoxDecoration(
                          color: colors.successBg,
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 20, color: colors.successFg),
                            const SizedBox(width: AppSpacing.s2),
                            Expanded(
                              child: Text(
                                t.loginPasswordChangedMessage,
                                style: textTheme.bodyMedium?.copyWith(color: colors.successFg),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                    ],
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
                      focusNode: _emailFocus,
                      autovalidateMode: AutovalidateMode.always,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) {
                        if (!_emailDirty) setState(() => _emailDirty = true);
                      },
                      validator: _validateEmail,
                      decoration: InputDecoration(
                        labelText: t.loginEmailLabel,
                        hintText: t.loginEmailHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      autovalidateMode: AutovalidateMode.always,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (_) {
                        if (!_passwordDirty) setState(() => _passwordDirty = true);
                      },
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
