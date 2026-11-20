import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

/// Emoji in a tinted rounded square (prototype `.cat-ic`).
class CatIcon extends StatelessWidget {
  const CatIcon({super.key, required this.icon, required this.color, this.size = 40});

  final String icon;

  /// `#RRGGBB`.
  final String color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: softColor(color),
            borderRadius: BorderRadius.circular(size * .3),
          ),
          child: Text(icon, style: TextStyle(fontSize: size * .5)),
        ),
      );
}
