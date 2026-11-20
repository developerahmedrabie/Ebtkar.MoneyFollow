import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/money/format.dart';
import '../../core/time/dates.dart';
import '../../data/backup/backup_service.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

Future<BackupService> backupServiceFor(WidgetRef ref) async {
  final info = await PackageInfo.fromPlatform();
  return BackupService(ref.read(dbProvider),
      appVersion: '${info.version}+${info.buildNumber}',
      deviceName: Platform.isIOS ? 'iPhone' : 'Android');
}

/// "Back up now": optional password, then the share sheet (FR-061).
Future<void> backupNow(BuildContext context, WidgetRef ref) async {
  final l = context.l;
  final pass = await showDialog<String?>(
    context: context,
    builder: (_) => const _PasswordDialog(confirm: true),
  );
  if (pass == null) return; // cancelled ('' = no password)
  final service = await backupServiceFor(ref);
  final bytes = await service.createBackup(password: pass.isEmpty ? null : pass);
  final dir = await getTemporaryDirectory();
  final f = File('${dir.path}/${BackupService.fileName(ref.read(todayProvider))}');
  await f.writeAsBytes(bytes);
  await ref.read(prefsProvider).setLastBackupAt(DateTime.now().millisecondsSinceEpoch);
  ref.invalidate(_lastBackupProvider);
  await SharePlus.instance.share(
      ShareParams(files: [XFile(f.path, mimeType: 'application/octet-stream')]));
  if (context.mounted) showToast(context, l.backupCreated);
}

/// "Restore from backup": pick, password if needed, confirm, replace.
/// Returns true when data was restored.
Future<bool> restoreFromBackup(BuildContext context, WidgetRef ref) async {
  final l = context.l;
  final picked = await FilePicker.pickFiles();
  if (picked.isEmpty || !context.mounted) return false;
  final data = Uint8List.fromList(await picked.single.readAsBytes());
  if (!context.mounted) return false;
  final service = await backupServiceFor(ref);
  String? error;
  BackupHeader header;
  try {
    header = service.readHeader(data);
  } on BackupError {
    if (context.mounted) _error(context, l.errBackupDamaged);
    return false;
  }
  if (!context.mounted) return false;
  String? password;
  while (true) {
    if (header.encrypted) {
      password = await showDialog<String?>(
          context: context, builder: (_) => _PasswordDialog(confirm: false, error: error));
      if (password == null || !context.mounted) return false;
    }
    final created = header.createdAt.length >= 10 ? header.createdAt.substring(0, 10) : header.createdAt;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restoreConfirmTitle),
        content: Text(
            '${l.restoreConfirmBody(dateShort(created, context.lang), header.deviceName, '${header.counts['transactions'] ?? 0}')}\n'
            '${(header.size / 1024).toStringAsFixed(0)} KB'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.restore)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return false;
    try {
      await service.restore(data, password: password);
      final created = DateTime.tryParse(header.createdAt);
      await ref.read(prefsProvider).setLastBackupAt(
          (created ?? DateTime.now()).millisecondsSinceEpoch);
      ref.invalidate(familyDataProvider);
      if (context.mounted) showToast(context, l.restored);
      return true;
    } on BackupWrongPassword {
      error = l.errBackupPassword;
      continue;
    } on BackupNewerVersion {
      if (context.mounted) _error(context, l.errBackupNewer);
      return false;
    } on BackupError {
      if (context.mounted) _error(context, l.errBackupDamaged);
      return false;
    }
  }
}

void _error(BuildContext context, String msg) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.l.ok))],
      ),
    );

final _lastBackupProvider = Provider<int?>((ref) => ref.watch(prefsProvider).lastBackupAt);

/// Backup & restore (FR-061, FR-062).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final prefs = ref.watch(prefsProvider);
    final last = ref.watch(_lastBackupProvider);
    final lastText = last == null
        ? l.neverBackedUp
        : l.lastBackup(dateShort(LocalDate.today(DateTime.fromMillisecondsSinceEpoch(last)), context.lang));
    return PageScaffold(showBack: true, title: l.backup, children: [
      AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(lastText, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.backup_outlined),
            onPressed: () => backupNow(context, ref),
            label: Text(l.backupNow),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.restore),
            onPressed: () => restoreFromBackup(context, ref),
            label: Text(l.restoreBackup),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SwitchListTile(
          title: Text(l.backupReminder),
          value: prefs.backupReminder != 'off',
          onChanged: (v) async {
            await prefs.setBackupReminder(v ? 'on' : 'off');
            setState(() {});
          },
        ),
      ),
      HintText(l.backupPasswordHint),
    ]);
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.confirm, this.error});
  final bool confirm;
  final String? error;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  late String? _error = widget.error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      title: Text(widget.confirm ? l.backup : l.enterPassword),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.confirm) Text(l.backupPasswordHint),
        const SizedBox(height: 8),
        TextField(
          controller: _a,
          obscureText: true,
          decoration: InputDecoration(labelText: widget.confirm ? l.backupPassword : l.password, errorText: _error),
        ),
        if (widget.confirm) ...[
          const SizedBox(height: 8),
          TextField(controller: _b, obscureText: true, decoration: InputDecoration(labelText: l.backupPasswordConfirm)),
        ],
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (widget.confirm && _a.text != _b.text) {
              setState(() => _error = l.errPasswordMatch);
              return;
            }
            Navigator.pop(context, _a.text);
          },
          child: Text(widget.confirm ? l.backupNow : l.ok),
        ),
      ],
    );
  }
}
