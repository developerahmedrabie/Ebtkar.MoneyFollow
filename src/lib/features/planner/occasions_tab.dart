import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/format.dart';
import '../../core/theme/app_theme.dart';
import '../../core/time/dates.dart';
import '../../data/db/app_database.dart';
import '../../data/remote/occasion_dates_service.dart';
import '../../domain/builtin_occasions.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../home/coming_up_card.dart';
import '../sheets/occasion_sheet.dart';

/// Refreshes occasion dates and shows the result toast (FR-035).
Future<void> refreshOccasionDates(BuildContext context, WidgetRef ref, String country) async {
  final l = context.l;
  final messenger = ScaffoldMessenger.of(context);
  final r = await ref
      .read(occasionDatesServiceProvider)
      .refresh(country, ref.read(todayProvider));
  messenger.showSnackBar(SnackBar(
      content: Text(switch (r.status) {
    DatesRefreshStatus.updated => l.evSynced('${r.count}'),
    DatesRefreshStatus.noHolidayData => l.evNoHoliday,
    DatesRefreshStatus.failed => l.evSyncFail,
  })));
}

/// Planner › Occasions (REQUIREMENTS §7.10, prototype `renderOccasions`).
class OccasionsTab extends ConsumerStatefulWidget {
  const OccasionsTab({super.key});

  @override
  ConsumerState<OccasionsTab> createState() => _OccasionsTabState();
}

class _OccasionsTabState extends ConsumerState<OccasionsTab> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    final today = ref.watch(todayProvider);
    return DataBuilder(builder: (context, d) {
      final s = ref.watch(occasionServiceProvider);
      if (s == null) return const SizedBox.shrink();
      final labels = labelsFor(context, ref, d);
      final up = s.upcoming();
      final total = up.fold(0, (a, x) => a + s.predict(x.$1).total);
      final next = up.firstOrNull;
      final updated = d.settings[SettingKeys.occasionDatesUpdatedAt];

      Future<void> sync() async {
        setState(() => _syncing = true);
        await refreshOccasionDates(context, ref, d.country);
        if (mounted) setState(() => _syncing = false);
      }

      return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 32), children: [
        Row(children: [
          Expanded(child: KpiTile(label: l.evTotal12, value: mainMoney(context, d, total), valueColor: c.warn)),
          const SizedBox(width: 10),
          Expanded(
            child: KpiTile(
              label: l.evNext,
              value: next == null ? '—' : labels.occasion(next.$1, s),
              sub: next == null
                  ? null
                  : (s.isHappening(next.$1) ? l.evNow : l.daysLeft('${LocalDate.daysBetween(today, next.$2)}')),
            ),
          ),
        ]),
        SectionHeader(l.evUpcoming),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: up.isEmpty
              ? EmptyState(l.evNone)
              : Column(children: [
                  for (final (key, date) in up)
                    () {
                      final o = s.byKey[key]!;
                      final p = s.predict(key);
                      final ch = p.history.length > 1 ? ((p.growth - 1) * 100).round() : null;
                      return InkWell(
                        onTap: () => context.push('/occasions/$key'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(children: [
                            CatIcon(icon: o.icon, color: o.color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(labels.occasion(key, s), style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 3),
                                Row(children: [
                                  occasionCountdown(context, s.isHappening(key), date, today),
                                  const SizedBox(width: 6),
                                  Text(dateShort(date, context.lang), style: TextStyle(fontSize: 12, color: c.muted)),
                                ]),
                              ]),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text(formatApprox(p.total, d.main, context.lang),
                                  style: TextStyle(fontWeight: FontWeight.w700, color: c.warn)),
                              if (p.last != null)
                                Text(
                                    '${l.evLast(mainMoney(context, d, p.last!.total))}${ch == null ? '' : ' · ${ch >= 0 ? '↑' : '↓'}${ch.abs()}%'}',
                                    style: TextStyle(fontSize: 11, color: c.muted)),
                            ]),
                          ]),
                        ),
                      );
                    }(),
                ]),
        ),
        HintText(l.evHint),
        SectionHeader(l.evSrcTitle),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(l.evCountry),
              const Spacer(),
              DropdownButton<String>(
                value: d.country,
                underline: const SizedBox.shrink(),
                items: [
                  for (final cc in supportedCountries)
                    DropdownMenuItem(value: cc, child: Text(labels.country(cc))),
                ],
                onChanged: (v) async {
                  if (v == null || v == d.country) return;
                  await ref.read(settingsRepoProvider).write(SettingKeys.country, v);
                  if (context.mounted) await refreshOccasionDates(context, ref, v);
                },
              ),
            ]),
            HintText(l.evSources),
            Row(children: [
              Expanded(
                child: Text(updated == null ? l.evBuiltin : l.evUpdated(dateShort(updated, context.lang)),
                    style: TextStyle(fontSize: 12, color: c.muted)),
              ),
              FilledButton.tonal(
                onPressed: _syncing ? null : sync,
                child: Text(_syncing ? l.evSyncing : l.evSync),
              ),
            ]),
          ]),
        ),
        SectionHeader(l.evTracked,
            link: l.addOccasion, onLink: () => OccasionSheet.show(context)),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(children: [
            for (final o in s.all)
              SwitchListTile(
                value: s.isEnabled(o.key),
                onChanged: (v) => ref.read(occasionsRepoProvider).setEnabled(o.key, v),
                secondary: CatIcon(icon: o.icon, color: o.color, size: 36),
                title: Text(labels.occasion(o.key, s)),
                subtitle: Text(labels.occasionSource(o.source)),
              ),
          ]),
        ),
      ]);
    });
  }
}
