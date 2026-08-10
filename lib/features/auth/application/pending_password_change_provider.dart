import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges the login screen and the forced change-password screen for a
/// first-login employee. Deliberately in-memory only (never written to
/// [TokenStorage]/secure storage) — if the app is killed mid-flow, the
/// employee simply has to log in again rather than an unvalidated
/// temp-password token surviving as a persisted session.
class PendingPasswordChange {
  const PendingPasswordChange({required this.accessToken});

  final String accessToken;
}

final pendingPasswordChangeProvider = StateProvider<PendingPasswordChange?>((ref) => null);

/// One-shot signal read by the login screen to show a "password changed,
/// please log in" banner after a successful forced change. Cleared by the
/// login screen itself once shown.
final passwordJustChangedProvider = StateProvider<bool>((ref) => false);
