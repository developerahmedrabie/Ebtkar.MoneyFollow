import 'dart:convert';

import 'package:local_auth/local_auth.dart';

import '../core/crypto/kdf.dart';
import '../data/prefs/secure_store.dart';

/// PIN (4–6 digits, salted Argon2id hash in secure storage) and biometrics
/// with the PIN as fallback (FR-057).
class AppLockService {
  AppLockService(this.store, [LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final SecureStore store;
  final LocalAuthentication _auth;

  /// Lock again after this long in the background.
  static const relockAfter = Duration(seconds: 60);

  static bool validPin(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  Future<String> _hash(String pin, List<int> salt) async {
    final key = await deriveKey(pin, KdfParams(salt: salt));
    return base64Encode(await key.extractBytes());
  }

  Future<void> setPin(String pin) async {
    if (!validPin(pin)) throw ArgumentError('PIN must be 4–6 digits');
    final salt = randomBytes(16);
    await store.write(SecureStore.pinSalt, base64Encode(salt));
    await store.write(SecureStore.pinHash, await _hash(pin, salt));
  }

  Future<bool> hasPin() async => await store.read(SecureStore.pinHash) != null;

  Future<bool> checkPin(String pin) async {
    final salt = await store.read(SecureStore.pinSalt);
    final hash = await store.read(SecureStore.pinHash);
    if (salt == null || hash == null) return false;
    return await _hash(pin, base64Decode(salt)) == hash;
  }

  Future<void> clearPin() async {
    await store.delete(SecureStore.pinHash);
    await store.delete(SecureStore.pinSalt);
  }

  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true);
    } catch (_) {
      return false;
    }
  }
}
