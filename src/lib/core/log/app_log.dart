import 'dart:io';

/// Local ring-buffer log (research R-19). Nothing leaves the phone unless
/// the user shares it from Settings › About.
class AppLog {
  AppLog._(this._file);

  static const maxLines = 500;
  static AppLog? _instance;

  final File? _file;
  final List<String> _lines = [];

  static AppLog get instance => _instance ??= AppLog._(null);

  /// Opens the log file in [directory] (the app documents directory).
  static Future<AppLog> init(Directory directory) async {
    final f = File('${directory.path}${Platform.pathSeparator}moneyfollow.log');
    final log = AppLog._(f);
    if (await f.exists()) {
      final lines = await f.readAsLines();
      log._lines.addAll(lines.length > maxLines
          ? lines.sublist(lines.length - maxLines)
          : lines);
    }
    _instance = log;
    return log;
  }

  void log(String message) => _add('I', message);

  void error(Object error, [StackTrace? stack]) =>
      _add('E', '$error${stack == null ? '' : '\n$stack'}');

  void _add(String level, String message) {
    final ts = DateTime.now().toUtc().toIso8601String();
    for (final line in '$ts $level $message'.split('\n')) {
      _lines.add(line);
    }
    if (_lines.length > maxLines) {
      _lines.removeRange(0, _lines.length - maxLines);
    }
    _flush();
  }

  Future<void>? _pending;
  void _flush() {
    final f = _file;
    if (f == null) return;
    _pending = (_pending ?? Future.value()).then((_) =>
        f.writeAsString('${_lines.join('\n')}\n').then((_) {}, onError: (_) {}));
  }

  String readAll() => _lines.join('\n');
}
