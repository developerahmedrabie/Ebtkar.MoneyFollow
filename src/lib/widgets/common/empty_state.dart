import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.mc.muted)),
        ),
      );
}
