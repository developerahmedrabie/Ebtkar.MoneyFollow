import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../services/app_lock_state.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../lock/lock_screen.dart';

/// App lock: Off / PIN / PIN + biometrics (FR-057).
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _bioAvailable = false;

  @override
  void initState() {
    super.initState();
    ref.read(appLockServiceProvider).canUseBiometrics().then((v) {
      if (mounted) setState(() => _bioAvailable = v);
    });
  }

  Future<bool> _setPin() async {
    final pin = await Navigator.of(context).push<String>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const _SetPinPage()),
    );
    if (pin == null) return false;
    await ref.read(appLockServiceProvider).setPin(pin);
    return true;
  }

  Future<void> _mode(String mode) async {
    final svc = ref.read(appLockServiceProvider);
    if (mode == 'off') {
      await svc.clearPin();
    } else if (!await svc.hasPin()) {
      if (!await _setPin()) return;
    }
    await ref.read(appLockProvider.notifier).setMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final mode = ref.watch(appLockProvider).mode;
    return PageScaffold(showBack: true, title: l.security, children: [
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: RadioGroup<String>(
          groupValue: mode,
          onChanged: (v) => _mode(v ?? 'off'),
          child: Column(children: [
            RadioListTile<String>(value: 'off', title: Text(l.lockOff)),
            RadioListTile<String>(value: 'pin', title: Text(l.lockPin)),
            RadioListTile<String>(
              value: 'biometric',
              enabled: _bioAvailable,
              title: Text(l.lockBiometric),
            ),
          ]),
        ),
      ),
      if (mode != 'off') ...[
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ListTile(
            leading: const Icon(Icons.pin_outlined),
            title: Text(l.changePin),
            onTap: _setPin,
          ),
        ),
      ],
      HintText(l.pinHint),
    ]);
  }
}

class _SetPinPage extends StatefulWidget {
  const _SetPinPage();
  @override
  State<_SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<_SetPinPage> {
  String _pin = '';
  String? _first;
  String? _error;

  void _next() {
    if (_pin.length < 4) return;
    if (_first == null) {
      setState(() {
        _first = _pin;
        _pin = '';
      });
    } else if (_first == _pin) {
      Navigator.pop(context, _pin);
    } else {
      setState(() {
        _first = null;
        _pin = '';
        _error = context.l.errPinMatch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    return Scaffold(
      appBar: AppBar(title: Text(l.setPin)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            Text(_error ?? (_first == null ? l.enterPin : l.confirmPin),
                style: TextStyle(color: _error == null ? c.muted : c.expense)),
            Text(l.pinHint, style: TextStyle(fontSize: 12, color: c.muted)),
            const SizedBox(height: 16),
            PinPad(
              length: _pin.length,
              onDigit: (d) {
                if (_pin.length < 6) setState(() => _pin += d);
              },
              onBack: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _pin.length >= 4 ? _next : null, child: Text(l.next)),
          ]),
        ),
      ),
    );
  }
}
