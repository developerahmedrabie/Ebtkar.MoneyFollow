import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secrets kept in the platform keystore (PIN hash, sync keys).
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
      : _s = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _s;

  static const pinHash = 'pin_hash';
  static const pinSalt = 'pin_salt';

  Future<String?> read(String key) => _s.read(key: key);
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);
  Future<void> delete(String key) => _s.delete(key: key);
}
