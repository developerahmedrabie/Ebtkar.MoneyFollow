import 'package:money_follow/core/time/hlc.dart';
import 'package:test/test.dart';

void main() {
  test('timestamps are monotonic even when the wall clock moves backwards',
      () {
    var now = 1000;
    final h = Hlc(deviceId: 'devA', wallClock: () => now);
    final a = h.send();
    now = 900; // clock moved back
    final b = h.send();
    final c = h.send();
    now = 2000;
    final d = h.send();
    expect(a.compareTo(b) < 0, isTrue);
    expect(b.compareTo(c) < 0, isTrue);
    expect(c.compareTo(d) < 0, isTrue);
  });

  test('receive() advances past the remote time', () {
    var now = 1000;
    final h = Hlc(deviceId: 'devA', wallClock: () => now);
    final remote = Hlc.format(5000, 7, 'devB');
    h.receive(remote);
    final next = h.send();
    expect(next.compareTo(remote) > 0, isTrue);
    expect(Hlc.parse(next).ms, 5000);
    now = 6000;
    expect(Hlc.parse(h.send()).ms, 6000);
  });

  test('format and parse round-trip', () {
    final s = Hlc.format(1731500000000, 3, 'dev-1');
    expect(s, '1731500000000-0003-dev-1');
    final p = Hlc.parse(s);
    expect(p.ms, 1731500000000);
    expect(p.counter, 3);
    expect(p.deviceId, 'dev-1');
  });
}
