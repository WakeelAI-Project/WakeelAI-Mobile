import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/forgot_password_controller.dart';
import '../domain/auth_exceptions.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _emailTouched = false;
  bool _emailDirty = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() {
        if (_emailFocus.hasFocus) _isSubmitting = false;
        if (!_emailFocus.hasFocus) _emailTouched = true;
      });
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _emailController.dispose();
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

  Future<void> _submit(bool isLoading) async {
    if (isLoading) return;
    setState(() => _isSubmitting = true);
    if (_formKey.currentState?.validate() != true) return;

    final email = _emailController.text.trim();
    await ref.read(forgotPasswordControllerProvider.notifier).submit(email: email);
    final state = ref.read(forgotPasswordControllerProvider);
    if (mounted && !state.hasError) {
      context.push('/verify-otp', extra: email);
    }
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is ForgotPasswordFailure) {
      switch (error.reason) {
        case ForgotPasswordFailureReason.tooManyRequests:
          return t.forgotPasswordTooManyRequests;
        case ForgotPasswordFailureReason.unknown:
          return t.forgotPasswordGenericError;
      }
    }
    return t.forgotPasswordGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);
    final isLoading = forgotPasswordState.isLoading;

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
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
                    Center(child: BrandMark(size: 56, fillColor: colors.brandPrimary)),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      t.forgotPasswordTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      t.forgotPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (forgotPasswordState.hasError) ...[
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
                                _errorMessage(t, forgotPasswordState.error),
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
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) {
                        if (!_emailDirty) setState(() => _emailDirty = true);
                      },
                      validator: _validateEmail,
                      onFieldSubmitted: (_) => _submit(isLoading),
                      decoration: InputDecoration(
                        labelText: t.loginEmailLabel,
                        hintText: t.loginEmailHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    ElevatedButton(
                      style: AppButtonStyles.primary(context),
                      onPressed: () => _submit(isLoading),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                            )
                          : Text(t.forgotPasswordSubmit),
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
