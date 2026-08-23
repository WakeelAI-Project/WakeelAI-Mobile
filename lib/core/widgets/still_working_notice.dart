import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../network/dio_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A one-line "Still working…" reassurance that appears only once a request
/// has been running for [delay].
///
/// The backend sleeps when idle, so the first call of a session can take
/// most of [apiRequestTimeout] to answer. Mount this next to a loading
/// state: it stays invisible for a normal request and only speaks up when
/// the wait is long enough that the user would otherwise assume the app is
/// stuck.
class StillWorkingNotice extends StatefulWidget {
  const StillWorkingNotice({super.key, this.delay = slowRequestHintDelay});

  final Duration delay;

  @override
  State<StillWorkingNotice> createState() => _StillWorkingNoticeState();
}

class _StillWorkingNoticeState extends State<StillWorkingNotice> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        l10n.stillWorkingNotice,
        textAlign: TextAlign.center,
        style: AppTypography.textSm(l10n.localeName == 'ar').copyWith(color: colors.textSecondary),
      ),
    );
  }
}
