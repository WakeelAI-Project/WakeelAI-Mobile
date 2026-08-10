import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/seal_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/change_password_controller.dart';
import '../domain/auth_exceptions.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _currentPasswordTouched = false;
  bool _newPasswordTouched = false;
  bool _confirmPasswordTouched = false;
  bool _currentPasswordDirty = false;
  bool _newPasswordDirty = false;
  bool _confirmPasswordDirty = false;
  bool _isSubmitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _currentPasswordFocus.addListener(() {
      setState(() {
        if (_currentPasswordFocus.hasFocus) _isSubmitting = false;
        if (!_currentPasswordFocus.hasFocus) _currentPasswordTouched = true;
      });
    });
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
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (_currentPasswordFocus.hasFocus && !_isSubmitting) return null;
    if (!_currentPasswordTouched && !_isSubmitting) return null;
    if (!_currentPasswordDirty && !_isSubmitting) return null;

    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) return t.changePasswordErrorCurrentPasswordRequired;
    return null;
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

  void _submit(bool isLoading) {
    if (isLoading) return;
    setState(() => _isSubmitting = true);
    if (_formKey.currentState?.validate() != true) return;
    ref.read(changePasswordControllerProvider.notifier).submit(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is ChangePasswordFailure) {
      switch (error.reason) {
        case ChangePasswordFailureReason.invalidCurrentPassword:
          return t.changePasswordInvalidCurrentPassword;
        case ChangePasswordFailureReason.userNotFound:
          return t.changePasswordUserNotFound;
        case ChangePasswordFailureReason.unknown:
          return t.changePasswordGenericError;
      }
    }
    return t.changePasswordGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final changePasswordState = ref.watch(changePasswordControllerProvider);
    final isLoading = changePasswordState.isLoading;

    return Scaffold(
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
                    Text(t.changePasswordTitle, textAlign: TextAlign.center, style: textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      t.changePasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (changePasswordState.hasError) ...[
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
                                _errorMessage(t, changePasswordState.error),
                                style: textTheme.bodyMedium?.copyWith(color: colors.errorFg),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                    ],
                    TextFormField(
                      controller: _currentPasswordController,
                      focusNode: _currentPasswordFocus,
                      autovalidateMode: AutovalidateMode.always,
                      enabled: !isLoading,
                      obscureText: _obscureCurrentPassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (_) {
                        if (!_currentPasswordDirty) setState(() => _currentPasswordDirty = true);
                      },
                      validator: _validateCurrentPassword,
                      decoration: InputDecoration(
                        labelText: t.changePasswordCurrentPasswordLabel,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          tooltip: _obscureCurrentPassword ? t.loginShowPassword : t.loginHidePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
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
                          : Text(t.changePasswordSubmit),
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
