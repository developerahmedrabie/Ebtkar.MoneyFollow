import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/log/app_log.dart';
import '../../core/money/currency.dart';
import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../data/export/csv_writer.dart';
import '../../domain/balances.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../sheets/transfer_sheet.dart';
import 'debug_section.dart';
import 'rates_section.dart';

/// Settings (REQUIREMENTS §7.14, prototype `renderMore`).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: DataBuilder(builder: (context, d) {
        final labels = labelsFor(context, ref, d);
        final balances = accountBalances(d);
        Widget nav(IconData icon, String title, String route, {String? chip}) => ListTile(
              leading: Icon(icon),
              title: Text(title),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (chip != null) ChipLabel(chip),
                const Icon(Icons.chevron_right),
              ]),
              onTap: () => context.push(route),
            );
        return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
          SectionHeader(l.accounts,
              link: l.transfer, onLink: () => TransferSheet.show(context)),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              for (final b in balances)
                ListTile(
                  leading: Text(labels.accountIcon(b.account.id), style: const TextStyle(fontSize: 24)),
                  title: Text(labels.account(b.account.id)),
                  onTap: () => TransferSheet.show(context, fromAccount: b.account.id),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatAmount(b.balanceMinor, Currency.fromCode(b.account.currency), context.lang),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (b.account.currency != d.mainCurrency)
                        Text(formatApprox(b.mainApproxMinor, d.main, context.lang),
                            style: TextStyle(fontSize: 11, color: c.muted)),
                    ],
                  ),
                ),
              const Divider(height: 1),
              ListTile(
                title: Text(l.totalIn(d.main.label(context.lang)), style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Text(mainMoney(context, d, totalInMain(d)),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          const RatesSection(),
          SectionHeader(l.prefs),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l.language),
                trailing: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('عربي')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {context.lang},
                  onSelectionChanged: (s) => ref.read(languageProvider.notifier).set(s.first),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l.theme),
                trailing: DropdownButton<String>(
                  value: ref.watch(themeProvider),
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'system', child: Text(l.system)),
                    DropdownMenuItem(value: 'light', child: Text(l.light)),
                    DropdownMenuItem(value: 'dark', child: Text(l.dark)),
                  ],
                  onChanged: (v) => ref.read(themeProvider.notifier).set(v ?? 'system'),
                ),
              ),
            ]),
          ),
          SectionHeader(l.settingsMore),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              nav(Icons.groups_outlined, l.famMembers, '/family', chip: l.nMembers('${d.members.length}')),
              nav(Icons.category_outlined, l.categories, '/settings/categories',
                  chip: l.nCats('${builtinCategoriesById.length}', '${d.userCategories.length}')),
              nav(Icons.notifications_outlined, l.notifications, '/settings/notifications'),
              nav(Icons.lock_outline, l.security, '/settings/security'),
              nav(Icons.cloud_sync_outlined, l.sync, '/settings/sync'),
            ]),
          ),
          SectionHeader(l.data),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              nav(Icons.backup_outlined, l.backup, '/settings/backup'),
              ListTile(
                leading: const Icon(Icons.table_view_outlined),
                title: Text(l.kExport),
                onTap: () async {
                  final bytes = buildCsv(
                      d,
                      CsvLabels(
                        lang: context.lang,
                        account: labels.account,
                        member: (id) => id == null ? '' : labels.member(id),
                        occasion: (id) => id == null ? '' : labels.occasion(id, ref.read(occasionServiceProvider)),
                        note: labels.note,
                      ));
                  final dir = await getTemporaryDirectory();
                  final f = File('${dir.path}/${csvFileName(ref.read(todayProvider))}');
                  await f.writeAsBytes(bytes);
                  await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'text/csv')]));
                },
              ),
            ]),
          ),
          SectionHeader(l.about),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(children: [
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, s) => ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l.version(s.data == null ? '' : '${s.data!.version}+${s.data!.buildNumber}')),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l.shareLog),
                onTap: () async {
                  final dir = await getTemporaryDirectory();
                  final f = File('${dir.path}/moneyfollow-log.txt');
                  await f.writeAsString(AppLog.instance.readAll());
                  await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'text/plain')]));
                },
              ),
            ]),
          ),
          const DebugSection(),
        ]);
      }),
    );
  }
}
