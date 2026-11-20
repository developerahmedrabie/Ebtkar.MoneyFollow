import 'package:material_ui/material_ui.dart';

/// Short confirmation after a save (contracts "Saved changes").
void showToast(BuildContext context, String message) {
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1800),
    ));
}
