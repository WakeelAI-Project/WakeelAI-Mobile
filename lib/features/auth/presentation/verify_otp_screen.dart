import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_button_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/seal_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../application/forgot_password_controller.dart';
import '../application/verify_otp_controller.dart';
import '../domain/auth_exceptions.dart';
import 'widgets/otp_boxes_field.dart';

const _resendCooldown = Duration(seconds: 60);
const _otpLength = 6;

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpBoxesKey = GlobalKey<OtpBoxesFieldState>();
  String _otp = '';

  Timer? _resendTicker;
  int _resendSecondsLeft = 0;
  bool _resendJustSucceeded = false;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTicker?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTicker?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldown.inSeconds);
    _resendTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendSecondsLeft -= 1;
        if (_resendSecondsLeft <= 0) timer.cancel();
      });
    });
  }

  Future<void> _resendCode() async {
    if (_resendSecondsLeft > 0) return;
    setState(() => _resendJustSucceeded = false);
    await ref.read(forgotPasswordControllerProvider.notifier).submit(email: widget.email);
    if (!mounted) return;
    final state = ref.read(forgotPasswordControllerProvider);
    if (!state.hasError) {
      setState(() => _resendJustSucceeded = true);
      _startResendCooldown();
    }
  }

  Future<void> _submit(bool isLoading) async {
    if (isLoading || _otp.length != _otpLength) return;

    await ref.read(verifyOtpControllerProvider.notifier).submit(email: widget.email, otp: _otp);
    if (!mounted) return;
    final state = ref.read(verifyOtpControllerProvider);
    if (!state.hasError) {
      context.push('/new-password', extra: (email: widget.email, otp: _otp));
    } else {
      _otpBoxesKey.currentState?.clear();
    }
  }

  String _errorMessage(AppLocalizations t, Object? error) {
    if (error is VerifyOtpFailure) {
      switch (error.reason) {
        case VerifyOtpFailureReason.invalidOtp:
          return t.verifyOtpErrorInvalidOtp;
        case VerifyOtpFailureReason.otpExpired:
          return t.verifyOtpErrorOtpExpired;
        case VerifyOtpFailureReason.tooManyAttempts:
          return t.verifyOtpErrorTooManyAttempts;
        case VerifyOtpFailureReason.unknown:
          return t.verifyOtpErrorGeneric;
      }
    }
    return t.verifyOtpErrorGeneric;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    final verifyState = ref.watch(verifyOtpControllerProvider);
    final resendState = ref.watch(forgotPasswordControllerProvider);
    final isLoading = verifyState.isLoading;
    final isResending = resendState.isLoading;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: SealMark.logomark(size: 56, ringColor: colors.brandPrimary)),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    t.verifyOtpTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    t.verifyOtpSubtitle(widget.email),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  if (verifyState.hasError) ...[
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
                              _errorMessage(t, verifyState.error),
                              style: textTheme.bodyMedium?.copyWith(color: colors.errorFg),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                  ],
                  if (!verifyState.hasError && _resendJustSucceeded) ...[
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
                              t.verifyOtpResendSuccess,
                              style: textTheme.bodyMedium?.copyWith(color: colors.successFg),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                  ],
                  OtpBoxesField(
                    key: _otpBoxesKey,
                    length: _otpLength,
                    enabled: !isLoading,
                    autofocus: true,
                    onChanged: (value) => setState(() => _otp = value),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: (isResending || _resendSecondsLeft > 0) ? null : _resendCode,
                      child: Text(
                        _resendSecondsLeft > 0
                            ? t.verifyOtpResendCodeCountdown(_resendSecondsLeft)
                            : t.verifyOtpResendCode,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  ElevatedButton(
                    style: AppButtonStyles.primary(context),
                    onPressed: _otp.length == _otpLength ? () => _submit(isLoading) : null,
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.onBrandPrimary),
                          )
                        : Text(t.verifyOtpSubmit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
