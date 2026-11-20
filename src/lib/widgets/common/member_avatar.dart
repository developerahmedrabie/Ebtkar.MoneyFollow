import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

/// Round emoji avatar on the member's soft colour (prototype `.av`).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar(
      {super.key, required this.avatar, required this.color, this.size = 36});

  final String avatar;
  final String color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration:
              BoxDecoration(color: softColor(color), shape: BoxShape.circle),
          child: Text(avatar, style: TextStyle(fontSize: size * .52)),
        ),
      );
}
