import 'package:cryptography/cryptography.dart';

/// Thrown when GCM authentication fails (wrong key or tampered data).
class WrongKey implements Exception {
  const WrongKey();
}

final _aes = AesGcm.with256bits();

/// AES-256-GCM with a random 12-byte nonce. Returns the nonce and
/// ciphertext‖tag.
Future<({List<int> nonce, List<int> cipherText})> encrypt(
    SecretKey key, List<int> plain) async {
  final box = await _aes.encrypt(plain, secretKey: key);
  return (nonce: box.nonce, cipherText: [...box.cipherText, ...box.mac.bytes]);
}

Future<List<int>> decrypt(
    SecretKey key, List<int> nonce, List<int> cipherAndTag) async {
  if (cipherAndTag.length < 16) throw const WrongKey();
  final split = cipherAndTag.length - 16;
  try {
    return await _aes.decrypt(
      SecretBox(cipherAndTag.sublist(0, split),
          nonce: nonce, mac: Mac(cipherAndTag.sublist(split))),
      secretKey: key,
    );
  } on SecretBoxAuthenticationError {
    throw const WrongKey();
  }
}
