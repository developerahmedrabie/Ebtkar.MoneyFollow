import 'package:shared_preferences/shared_preferences.dart';

import '../../core/ids.dart';

/// Device-only preferences (not synced, FR-056).
class DevicePrefs {
  DevicePrefs(this._p);

  final SharedPreferences _p;

  static Future<DevicePrefs> load() async {
    final p = DevicePrefs(await SharedPreferences.getInstance());
    p.deviceId; // generate once
    return p;
  }

  static const _language = 'language';
  static const _theme = 'theme';
  static const _setupCompleted = 'setup_completed';
  static const _sampleMode = 'sample_mode';
  static const _sampleStartedAt = 'sample_started_at';
  static const _deviceId = 'device_id';
  static const _lastBackupAt = 'last_backup_at';
  static const _backupReminder = 'backup_reminder';
  static const _notifBills = 'notifications.bills';
  static const _notifBudgets = 'notifications.budgets';
  static const _notifOccasions = 'notifications.occasions';
  static const _appLock = 'app_lock';
  static const _lastDataChangeAt = 'last_data_change_at';

  /// `ar` | `en`.
  String? get language => _p.getString(_language);
  Future<void> setLanguage(String v) => _p.setString(_language, v);

  /// `system` | `light` | `dark`.
  String get theme => _p.getString(_theme) ?? 'system';
  Future<void> setTheme(String v) => _p.setString(_theme, v);

  bool get setupCompleted => _p.getBool(_setupCompleted) ?? false;
  Future<void> setSetupCompleted(bool v) => _p.setBool(_setupCompleted, v);

  bool get sampleMode => _p.getBool(_sampleMode) ?? false;
  Future<void> setSampleMode(bool v) => _p.setBool(_sampleMode, v);

  /// UTC ms when sample mode started.
  int? get sampleStartedAt => _p.getInt(_sampleStartedAt);
  Future<void> setSampleStartedAt(int? v) => v == null
      ? _p.remove(_sampleStartedAt)
      : _p.setInt(_sampleStartedAt, v);

  String get deviceId {
    var id = _p.getString(_deviceId);
    if (id == null) {
      id = newId();
      _p.setString(_deviceId, id);
    }
    return id;
  }

  /// UTC ms of the last backup.
  int? get lastBackupAt => _p.getInt(_lastBackupAt);
  Future<void> setLastBackupAt(int v) => _p.setInt(_lastBackupAt, v);

  /// UTC ms of the last local data change.
  int? get lastDataChangeAt => _p.getInt(_lastDataChangeAt);
  Future<void> setLastDataChangeAt(int v) => _p.setInt(_lastDataChangeAt, v);

  /// `on` | `snoozed_until:<YYYY-MM-DD>` | `off`.
  String get backupReminder => _p.getString(_backupReminder) ?? 'on';
  Future<void> setBackupReminder(String v) => _p.setString(_backupReminder, v);

  bool get notifyBills => _p.getBool(_notifBills) ?? false;
  Future<void> setNotifyBills(bool v) => _p.setBool(_notifBills, v);
  bool get notifyBudgets => _p.getBool(_notifBudgets) ?? false;
  Future<void> setNotifyBudgets(bool v) => _p.setBool(_notifBudgets, v);
  bool get notifyOccasions => _p.getBool(_notifOccasions) ?? false;
  Future<void> setNotifyOccasions(bool v) => _p.setBool(_notifOccasions, v);

  /// `off` | `pin` | `biometric`.
  String get appLock => _p.getString(_appLock) ?? 'off';
  Future<void> setAppLock(String v) => _p.setString(_appLock, v);
}
