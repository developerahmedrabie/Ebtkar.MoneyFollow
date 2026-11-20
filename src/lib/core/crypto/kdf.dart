import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Argon2id parameters from contracts/backup-file.md.
class KdfParams {
  const KdfParams({
    required this.salt,
    this.memKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
  });

  final List<int> salt;
  final int memKiB;
  final int iterations;
  final int parallelism;
}

List<int> randomBytes(int n) {
  final r = Random.secure();
  return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
}

/// A new 16-byte salt with the default parameters.
KdfParams newKdfParams() => KdfParams(salt: randomBytes(16));

/// Derives a 256-bit key from [password].
Future<SecretKey> deriveKey(String password, KdfParams p) {
  final algo = Argon2id(
    memory: p.memKiB,
    iterations: p.iterations,
    parallelism: p.parallelism,
    hashLength: 32,
  );
  return algo.deriveKeyFromPassword(password: password, nonce: p.salt);
}
