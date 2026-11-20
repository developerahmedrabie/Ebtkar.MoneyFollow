import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/prefs/secure_store.dart';
import '../../l10n/l10n.dart';
import '../../services/app_lock.dart';
import '../../services/app_lock_state.dart';

final appLockServiceProvider =
    Provider<AppLockService>((ref) => AppLockService(SecureStore()));

/// PIN pad with an optional biometric button (FR-057).
class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.length, required this.onDigit, required this.onBack, this.extra});

  final int length;
  final ValueChanged<String> onDigit;
  final VoidCallback onBack;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    Widget key(String d) => SizedBox(
          width: 76,
          height: 64,
          child: TextButton(
            onPressed: () => onDigit(d),
            child: Text(d, style: TextStyle(fontSize: 26, color: c.text)),
          ),
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < 6; i++)
            Container(
              margin: const EdgeInsets.all(6),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < length ? c.primary : c.line,
              ),
            ),
        ]),
        const SizedBox(height: 16),
        for (final row in const [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (final d in row) key(d)]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(width: 76, height: 64, child: extra ?? const SizedBox.shrink()),
          key('0'),
          SizedBox(
            width: 76,
            height: 64,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const Icon(Icons.backspace_outlined),
              onPressed: onBack,
            ),
          ),
        ]),
      ]),
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(appLockProvider).mode == 'biometric') _bio();
    });
  }

  Future<void> _bio() async {
    final ok = await ref.read(appLockServiceProvider).authenticateBiometric(context.l.biometricReason);
    if (ok) ref.read(appLockProvider.notifier).unlock();
  }

  Future<void> _digit(String d) async {
    if (_checking || _pin.length >= 6) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length >= 4) {
      _checking = true;
      final ok = await ref.read(appLockServiceProvider).checkPin(_pin);
      _checking = false;
      if (ok) {
        ref.read(appLockProvider.notifier).unlock();
      } else if (_pin.length == 6 && mounted) {
        setState(() {
          _pin = '';
          _error = context.l.errPin;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final bio = ref.watch(appLockProvider).mode == 'biometric';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Icon(Icons.lock_outline, size: 48, color: c.primary),
              const SizedBox(height: 12),
              const Text('MoneyFollow', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(_error ?? l.enterPin, style: TextStyle(color: _error == null ? c.muted : c.expense)),
              const SizedBox(height: 18),
              PinPad(
                length: _pin.length,
                onDigit: _digit,
                onBack: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
                extra: bio
                    ? IconButton(tooltip: l.useBiometric, icon: const Icon(Icons.fingerprint), onPressed: _bio)
                    : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
