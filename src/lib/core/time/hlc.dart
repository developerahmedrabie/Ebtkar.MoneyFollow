/// Hybrid logical clock (research R-08, contracts/drive-sync.md "Clock").
///
/// Timestamps look like `1731500000000-0003-<deviceId>`: 13-digit (padded)
/// wall-clock milliseconds, a 4-digit counter and the device id. Plain string
/// comparison gives the causal order.
class Hlc {
  Hlc({required this.deviceId, int Function()? wallClock})
      : _wall = wallClock ?? (() => DateTime.now().millisecondsSinceEpoch);

  final String deviceId;
  final int Function() _wall;
  int _ms = 0;
  int _counter = 0;

  static const maxCounter = 9999;

  /// Timestamp for a local event.
  String send() {
    final now = _wall();
    if (now > _ms) {
      _ms = now;
      _counter = 0;
    } else {
      _bump();
    }
    return format(_ms, _counter, deviceId);
  }

  /// Merges a remote timestamp so later local events sort after it.
  void receive(String remote) {
    final r = parse(remote);
    final now = _wall();
    final ms = [now, _ms, r.ms].reduce((a, b) => a > b ? a : b);
    if (ms == _ms && ms == r.ms) {
      _counter = (_counter > r.counter ? _counter : r.counter) + 1;
    } else if (ms == _ms) {
      _counter++;
    } else if (ms == r.ms) {
      _counter = r.counter + 1;
    } else {
      _counter = 0;
    }
    _ms = ms;
    if (_counter > maxCounter) {
      _ms++;
      _counter = 0;
    }
  }

  void _bump() {
    _counter++;
    if (_counter > maxCounter) {
      _ms++;
      _counter = 0;
    }
  }

  static String format(int ms, int counter, String deviceId) =>
      '${ms.toString().padLeft(13, '0')}-'
      '${counter.toString().padLeft(4, '0')}-$deviceId';

  static ({int ms, int counter, String deviceId}) parse(String s) {
    final first = s.indexOf('-');
    final second = s.indexOf('-', first + 1);
    if (first < 0 || second < 0) throw FormatException('Bad HLC: $s');
    return (
      ms: int.parse(s.substring(0, first)),
      counter: int.parse(s.substring(first + 1, second)),
      deviceId: s.substring(second + 1),
    );
  }
}
