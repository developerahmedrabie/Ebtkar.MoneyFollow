import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/money/currency.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/app_database.dart';
import '../../data/sample/sample_mode_service.dart';
import '../../domain/builtin_occasions.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';
import '../planner/occasions_tab.dart';
import '../settings/backup_screen.dart';
import '../sheets/member_sheet.dart';

const setupSteps = ['language', 'currency', 'members', 'start'];

/// First-launch setup (FR-063, FR-064). Every step can be skipped.
class SetupFlow extends ConsumerWidget {
  const SetupFlow({super.key, required this.step});
  final String step;

  void _next(BuildContext context) {
    final i = setupSteps.indexOf(step);
    if (i >= 0 && i < setupSteps.length - 1) context.go('/setup/${setupSteps[i + 1]}');
  }

  Future<void> _finish(WidgetRef ref, {required bool sample}) async {
    final prefs = ref.read(prefsProvider);
    if (sample) {
      final started = await SampleModeService(ref.read(dbProvider)).start(ref.read(todayProvider));
      await prefs.setSampleStartedAt(started);
      await prefs.setSampleMode(true);
    }
    await ref.read(setupProvider.notifier).complete();
    ref.read(setupProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.mc;
    final i = setupSteps.indexOf(step).clamp(0, 3);
    final title = [l.setupLanguage, l.setupCurrency, l.setupMembers, l.setupStart][i];

    final Widget body = switch (step) {
      'currency' => const _CurrencyStep(),
      'members' => const _MembersStep(),
      'start' => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _BigChoice(
            icon: Icons.auto_awesome_outlined,
            title: l.exploreSample,
            subtitle: l.exploreSampleHint,
            onTap: () => _finish(ref, sample: true),
          ),
          const SizedBox(height: 12),
          _BigChoice(
            icon: Icons.edit_note,
            title: l.startOwn,
            subtitle: l.startOwnHint,
            onTap: () => _finish(ref, sample: false),
          ),
        ]),
      _ => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (code, name) in const [('ar', 'العربية'), ('en', 'English')])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BigChoice(
                icon: Icons.translate,
                title: name,
                selected: context.lang == code,
                onTap: () => ref.read(languageProvider.notifier).set(code),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.restore),
            label: Text(l.restoreBackup),
            onPressed: () async {
              if (await restoreFromBackup(context, ref)) await _finish(ref, sample: false);
            },
          ),
        ]),
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24), children: [
          Text(l.setupWelcome, style: TextStyle(color: c.muted)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: (i + 1) / setupSteps.length),
          const SizedBox(height: 20),
          body,
          const SizedBox(height: 24),
          if (step != 'start')
            Row(children: [
              TextButton(onPressed: () => _next(context), child: Text(l.skip)),
              const Spacer(),
              FilledButton(onPressed: () => _next(context), child: Text(l.next)),
            ])
          else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(onPressed: () => _finish(ref, sample: false), child: Text(l.skip)),
            ),
        ]),
      ),
    );
  }
}

class _BigChoice extends StatelessWidget {
  const _BigChoice({required this.icon, required this.title, this.subtitle, this.selected = false, required this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? c.primarySoft : c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? c.primary : c.line, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: c.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              if (subtitle != null) Text(subtitle!, style: TextStyle(color: c.muted)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Main currency and country, defaulting from the device region.
class _CurrencyStep extends ConsumerStatefulWidget {
  const _CurrencyStep();
  @override
  ConsumerState<_CurrencyStep> createState() => _CurrencyStepState();
}

class _CurrencyStepState extends ConsumerState<_CurrencyStep> {
  static const _byCountry = {'EG': 'EGP', 'SA': 'SAR', 'AE': 'AED', 'KW': 'KWD', 'US': 'USD', 'GB': 'GBP'};

  @override
  void initState() {
    super.initState();
    final region = PlatformDispatcher.instance.locale.countryCode;
    if (region != null && supportedCountries.contains(region)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final s = ref.read(settingsRepoProvider);
        if (await s.country() == 'EG' && region != 'EG') {
          await s.write(SettingKeys.country, region);
          await s.write(SettingKeys.mainCurrency, _byCountry[region]!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return DataBuilder(builder: (context, d) {
      final labels = labelsFor(context, ref, d);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.mainCurrency),
        DropdownButtonFormField<Currency>(
          initialValue: d.main,
          items: [
            for (final c in Currency.values)
              DropdownMenuItem(value: c, child: Text('${c.code} · ${c.fullName(context.lang)}')),
          ],
          onChanged: (c) => ref.read(settingsRepoProvider).write(SettingKeys.mainCurrency, c!.code),
        ),
        FieldLabel(l.evCountry),
        DropdownButtonFormField<String>(
          initialValue: d.country,
          items: [
            for (final cc in supportedCountries) DropdownMenuItem(value: cc, child: Text(labels.country(cc))),
          ],
          onChanged: (v) async {
            if (v == null) return;
            await ref.read(settingsRepoProvider).write(SettingKeys.country, v);
            if (context.mounted) await refreshOccasionDates(context, ref, v);
          },
        ),
      ]);
    });
  }
}

class _MembersStep extends ConsumerWidget {
  const _MembersStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return DataBuilder(builder: (context, d) {
      final labels = labelsFor(context, ref, d);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        HintText(l.setupMembersHint),
        for (final m in d.members)
          ListTile(
            leading: MemberAvatar(avatar: m.avatar, color: m.color),
            title: Text(labels.memberName(m)),
            subtitle: Text(labels.role(m.role)),
            onTap: () => MemberSheet.show(context, memberId: m.id),
          ),
        OutlinedButton(onPressed: () => MemberSheet.show(context), child: Text(l.addMember)),
      ]);
    });
  }
}
