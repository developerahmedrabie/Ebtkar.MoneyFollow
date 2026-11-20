import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../data/repositories/base_repository.dart';
import '../../domain/builtin_categories.dart';
import '../../l10n/l10n.dart';
import '../../providers.dart';
import '../../widgets/common/common.dart';
import '../common/ui.dart';

/// Add / edit a family member (prototype `#msheet`).
class MemberSheet extends ConsumerStatefulWidget {
  const MemberSheet({super.key, this.memberId});
  final String? memberId;

  static Future<void> show(BuildContext context, {String? memberId}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => MemberSheet(memberId: memberId),
      );

  @override
  ConsumerState<MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends ConsumerState<MemberSheet> {
  final _name = TextEditingController();
  String _role = 'child';
  String _avatar = '👦';
  String? _error;

  @override
  void initState() {
    super.initState();
    final d = ref.read(familyDataProvider).value;
    final m = d?.membersById[widget.memberId];
    if (m != null) {
      _role = m.role;
      _avatar = m.avatar;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _name.text = labelsFor(context, ref, d!).memberName(m);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(membersRepoProvider);
      if (widget.memberId == null) {
        await repo.create(_name.text, _role, _avatar);
      } else {
        await repo.update(widget.memberId!, _name.text, _role, _avatar);
      }
    } on ValidationException {
      setState(() => _error = l.errName);
      return;
    }
    await ref.read(prefsProvider).setLastDataChangeAt(DateTime.now().millisecondsSinceEpoch);
    nav.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.tMemSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.mc;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: Text(widget.memberId == null ? l.newMember : l.editMember,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          ]),
          FieldLabel(l.name),
          TextField(
            controller: _name,
            maxLength: 30,
            autofocus: widget.memberId == null,
            decoration: InputDecoration(hintText: l.memPh, errorText: _error, counterText: ''),
            onChanged: (_) => setState(() => _error = null),
          ),
          FieldLabel(l.role),
          Segments<String>(
            value: _role,
            items: [('parent', l.roleParent), ('child', l.roleChild), ('other', l.roleOther)],
            onChanged: (v) => setState(() => _role = v),
          ),
          FieldLabel(l.avatar),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final a in memberAvatars)
              Semantics(
                button: true,
                selected: a == _avatar,
                label: a,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => setState(() => _avatar = a),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: a == _avatar ? c.primarySoft : c.surface2,
                      border: Border.all(color: a == _avatar ? c.primary : Colors.transparent, width: 2),
                    ),
                    child: Text(a, style: const TextStyle(fontSize: 26)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 18),
          FilledButton(onPressed: _save, child: Text(l.save)),
          if (widget.memberId != null) ...[
            const SizedBox(height: 10),
            ConfirmTwiceButton(
              label: l.delMember,
              onConfirmed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await ref.read(membersRepoProvider).remove(widget.memberId!);
                nav.pop();
                messenger.showSnackBar(SnackBar(content: Text(l.tMemDeleted)));
              },
            ),
            HintText(l.delMemHint),
          ],
        ]),
      ),
    );
  }
}
