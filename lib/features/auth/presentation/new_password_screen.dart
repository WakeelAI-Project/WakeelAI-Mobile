import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/seal_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/pending_password_change_provider.dart';
import '../application/reset_password_controller.dart';
import '../domain/auth_exceptions.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _newPasswordDirty = false;
  bool _confirmPasswordDirty = false;
  bool _isSubmitting = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _newPasswordFocus.addListener(() {
      setState(() {
        if (_newPasswordFocus.hasFocus) _isSubmitting = false;
        if (!_newPasswordFocus.hasFocus) _newPasswordTouched = true;
      });
    });
    _confirmPasswordFocus.addListener(() {
      setState(() {
        if (_confirmPasswordFocus.hasFocus) _isSubmitting = false;
        if (!_confirmPasswordFocus.hasFocus) _confirmPasswordTouched = true;
      });
    });
  }

  @override
  void dispose() {
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (_newPasswordFocus.hasFocus && !_isSubmitting) return null;
    if (!_newPasswordTouched && !_isSubmitting) return null;
    if (!_newPasswordDirty && !_isSubmitting) return null;

    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return t.changePasswordErrorPasswordRequired;
    if (value.length < 8) return t.changePasswordErrorPasswordTooShort;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_confirmPasswordFocus.hasFocus && !_isSubmitting) return null;
    if (!_confirmPasswordTouched && !_isSubmitting) return null;
    if (!_confirmPasswordDirty && !_isSubmitting) return null;

    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return t.changePasswordErrorPasswordRequired;
    if (value != _newPasswordController.text) return t.changePasswordErrorPasswordMismatch;
    return null;
  }

  Future<void> _submit(bool isLoading) async {
    if (isLoading) return;
    setState(() => _isSubmitting = true);
    if (_formKey.currentState?.validate() != true) return;

    await ref.read(resetPasswordControllerProvider.notifier).submit(
          email: widget.email,
          otp: widget.otp,
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;
    final state = ref.read(resetPasswordControllerProvider);
    if (!state.hasError) {
      ref.read(passwordJustChangedProvider.notifier).state = true;
      context.go('/login');
    }
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is ResetPasswordFailure) {
      switch (error.reason) {
        case ResetPasswordFailureReason.invalidOtp:
          return t.newPasswordErrorInvalidOtp;
        case ResetPasswordFailureReason.otpExpired:
          return t.newPasswordErrorOtpExpired;
        case ResetPasswordFailureReason.tooManyAttempts:
          return t.newPasswordErrorTooManyAttempts;
        case ResetPasswordFailureReason.validationError:
          return t.newPasswordErrorValidation;
        case ResetPasswordFailureReason.unknown:
          return t.newPasswordErrorGeneric;
      }
    }
    return t.newPasswordErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final resetState = ref.watch(resetPasswordControllerProvider);
    final isLoading = resetState.isLoading;

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
                    Center(child: SealMark.logomark(size: 56, ringColor: colors.brandPrimary)),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      t.newPasswordTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      t.newPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (resetState.hasError) ...[
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
                                _errorMessage(t, resetState.error),
                                style: textTheme.bodyMedium?.copyWith(color: colors.errorFg),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                    ],
                    TextFormField(
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocus,
                      autovalidateMode: AutovalidateMode.always,
                      enabled: !isLoading,
                      obscureText: _obscureNewPassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) {
                        if (!_newPasswordDirty) setState(() => _newPasswordDirty = true);
                      },
                      validator: _validateNewPassword,
                      decoration: InputDecoration(
                        labelText: t.changePasswordNewPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscureNewPassword ? t.loginShowPassword : t.loginHidePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    TextFormField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      autovalidateMode: AutovalidateMode.always,
                      enabled: !isLoading,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onChanged: (_) {
                        if (!_confirmPasswordDirty) setState(() => _confirmPasswordDirty = true);
                      },
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _submit(isLoading),
                      decoration: InputDecoration(
                        labelText: t.changePasswordConfirmPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscureConfirmPassword ? t.loginShowPassword : t.loginHidePassword,
                        ),
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
                          : Text(t.newPasswordSubmit),
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
