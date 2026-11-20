import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared HTTP rules (contracts/external-date-apis.md "Client rules"):
/// 10 s timeout, no retries, a User-Agent, at most 6 requests at a time.
class DateHttp {
  DateHttp(this.client, {this.version = '1.0.0'});

  final http.Client client;
  final String version;
  static const timeout = Duration(seconds: 10);
  static const maxParallel = 6;

  int _running = 0;
  final _waiting = <Completer<void>>[];

  Future<http.Response> get(Uri uri) async {
    if (_running >= maxParallel) {
      final c = Completer<void>();
      _waiting.add(c);
      await c.future;
    }
    _running++;
    try {
      return await client
          .get(uri, headers: {'User-Agent': 'MoneyFollow/$version'})
          .timeout(timeout);
    } finally {
      _running--;
      if (_waiting.isNotEmpty) _waiting.removeAt(0).complete();
    }
  }
}

/// Aladhan Hijri → Gregorian.
class AladhanClient {
  AladhanClient(this.http);
  final DateHttp http;

  /// Gregorian `YYYY-MM-DD` for Hijri [day]-[month]-[hijriYear], or null
  /// when the response isn't valid.
  Future<String?> hijriToGregorian(int day, int month, int hijriYear) async {
    String p(int n) => n.toString().padLeft(2, '0');
    final r = await http.get(Uri.parse(
        'https://api.aladhan.com/v1/hToG/${p(day)}-${p(month)}-$hijriYear'));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map || j['code'] != 200) return null;
    final date = (((j['data'] as Map?)?['gregorian']) as Map?)?['date'];
    if (date is! String) return null;
    final m = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(date);
    if (m == null) return null;
    return '${m[3]}-${m[2]}-${m[1]}';
  }
}

class Holiday {
  const Holiday(this.date, this.name);
  final String date;
  final String name;
}

/// Nager.Date public holidays. An empty list, 204 or 404 means "no data".
class NagerClient {
  NagerClient(this.http);
  final DateHttp http;

  /// Throws on network/server errors; returns [] for "no data".
  Future<List<Holiday>> publicHolidays(int year, String country) async {
    final r = await http.get(Uri.parse(
        'https://date.nager.at/api/v3/PublicHolidays/$year/$country'));
    if (r.statusCode == 204 || r.statusCode == 404) return const [];
    if (r.statusCode != 200) throw http_error(r.statusCode);
    if (r.body.trim().isEmpty) return const [];
    final j = jsonDecode(r.body);
    if (j is! List) return const [];
    return [
      for (final h in j)
        if (h is Map && h['date'] is String && h['name'] is String)
          Holiday(h['date'] as String, h['name'] as String),
    ];
  }

  // ignore: non_constant_identifier_names
  static Exception http_error(int code) => Exception('HTTP $code');
}
