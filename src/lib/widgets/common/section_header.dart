import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

/// Section title with an optional link on the other side.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.link, this.onLink});

  final String title;
  final String? link;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w700)),
            ),
            if (link != null)
              TextButton(
                onPressed: onLink,
                style: TextButton.styleFrom(
                    minimumSize: const Size(48, 40),
                    foregroundColor: context.mc.primary),
                child: Text(link!),
              ),
          ],
        ),
      );
}

/// A rounded card with padding (prototype `.card`).
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? context.mc.surface,
          borderRadius: BorderRadius.circular(18),
          border: color == null ? Border.all(color: context.mc.line) : null,
        ),
        child: child,
      );
}

/// Muted explanatory text (prototype `.hint`).
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
        child: Text(text,
            style: TextStyle(fontSize: 12.5, color: context.mc.muted, height: 1.45)),
      );
}

/// Label + value KPI tile.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.valueColor, this.sub});

  final String label;
  final String value;
  final Color? valueColor;
  final String? sub;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: context.mc.muted)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: valueColor)),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!, style: TextStyle(fontSize: 11.5, color: context.mc.muted)),
            ],
          ],
        ),
      );
}
