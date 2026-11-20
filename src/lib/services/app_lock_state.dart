import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class AppLockState {
  const AppLockState({required this.locked, required this.mode});
  final bool locked;

  /// `off` | `pin` | `biometric`.
  final String mode;
}

/// Whether the lock screen must be shown (FR-057). Locked on cold start
/// when the lock is on.
class AppLockNotifier extends Notifier<AppLockState> {
  @override
  AppLockState build() {
    final mode = ref.watch(prefsProvider).appLock;
    return AppLockState(locked: mode != 'off', mode: mode);
  }

  void lock() {
    if (state.mode != 'off') state = AppLockState(locked: true, mode: state.mode);
  }

  void unlock() => state = AppLockState(locked: false, mode: state.mode);

  Future<void> setMode(String mode) async {
    await ref.read(prefsProvider).setAppLock(mode);
    state = AppLockState(locked: false, mode: mode);
  }
}

final appLockProvider =
    NotifierProvider<AppLockNotifier, AppLockState>(AppLockNotifier.new);
