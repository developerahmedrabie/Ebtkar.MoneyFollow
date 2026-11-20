import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../core/crypto/aead.dart' as aead;
import '../../core/crypto/kdf.dart';

/// Errors from contracts/backup-file.md "Restore rules".
sealed class BackupError implements Exception {
  const BackupError();
}

class BackupDamaged extends BackupError {
  const BackupDamaged([this.reason = '']);
  final String reason;
  @override
  String toString() => 'BackupDamaged($reason)';
}

class BackupNewerVersion extends BackupError {
  const BackupNewerVersion();
}

class BackupWrongPassword extends BackupError {
  const BackupWrongPassword();
}

class BackupPasswordRequired extends BackupError {
  const BackupPasswordRequired();
}

class BackupHeader {
  const BackupHeader(this.json, {required this.encrypted, required this.size});
  final Map<String, dynamic> json;
  final bool encrypted;
  final int size;

  int get schemaVersion => (json['schemaVersion'] as num?)?.toInt() ?? 0;
  String get createdAt => json['createdAt'] as String? ?? '';
  String get deviceName => json['deviceName'] as String? ?? '';
  Map<String, int> get counts =>
      ((json['counts'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', (v as num).toInt()));
}

/// The `.mfbackup` container: magic, version, flags, plaintext header JSON,
/// body = gzip(payload JSON), optionally AES-256-GCM encrypted.
abstract final class BackupCodec {
  static const magic = 'MFBACKUP';
  static const containerVersion = 1;

  static Future<Uint8List> encode({
    required Map<String, dynamic> payload,
    required Map<String, dynamic> header,
    String? password,
  }) async {
    final zipped = gzip.encode(utf8.encode(jsonEncode(payload)));
    final h = {
      ...header,
      'payloadSha256': (await Sha256().hash(zipped)).bytes.map(_hex).join(),
    };
    List<int> body = zipped;
    if (password != null && password.isNotEmpty) {
      final kdf = newKdfParams();
      final key = await deriveKey(password, kdf);
      final box = await aead.encrypt(key, zipped);
      body = box.cipherText;
      h['kdf'] = {
        'alg': 'argon2id',
        'salt': base64Encode(kdf.salt),
        'memKiB': kdf.memKiB,
        'iterations': kdf.iterations,
        'parallelism': kdf.parallelism,
      };
      h['cipher'] = {'alg': 'aes-256-gcm', 'nonce': base64Encode(box.nonce)};
    }
    final hb = utf8.encode(jsonEncode(h));
    final out = BytesBuilder()
      ..add(ascii.encode(magic))
      ..add([0, containerVersion])
      ..addByte(password != null && password.isNotEmpty ? 1 : 0)
      ..add((ByteData(4)..setUint32(0, hb.length)).buffer.asUint8List())
      ..add(hb)
      ..add(body);
    return out.toBytes();
  }

  static String _hex(int b) => b.toRadixString(16).padLeft(2, '0');

  static (BackupHeader, int bodyOffset) _readHeader(Uint8List bytes) {
    if (bytes.length < 15 ||
        ascii.decode(bytes.sublist(0, 8), allowInvalid: true) != magic) {
      throw const BackupDamaged('magic');
    }
    final bd = ByteData.sublistView(bytes);
    if (bd.getUint16(8) != containerVersion) {
      throw const BackupDamaged('container version');
    }
    final flags = bytes[10];
    final hl = bd.getUint32(11);
    if (15 + hl > bytes.length) throw const BackupDamaged('header length');
    try {
      final json = jsonDecode(utf8.decode(bytes.sublist(15, 15 + hl)))
          as Map<String, dynamic>;
      return (
        BackupHeader(json, encrypted: flags & 1 == 1, size: bytes.length),
        15 + hl
      );
    } catch (_) {
      throw const BackupDamaged('header json');
    }
  }

  /// Reads the plaintext header (no password needed).
  static BackupHeader readHeader(Uint8List bytes) => _readHeader(bytes).$1;

  /// Decodes the payload. [appSchemaVersion] is this app's schema.
  static Future<Map<String, dynamic>> decode(Uint8List bytes,
      {String? password, required int appSchemaVersion}) async {
    final (h, offset) = _readHeader(bytes);
    if (h.schemaVersion > appSchemaVersion) throw const BackupNewerVersion();
    List<int> zipped = bytes.sublist(offset);
    if (h.encrypted) {
      if (password == null || password.isEmpty) {
        throw const BackupPasswordRequired();
      }
      try {
        final k = h.json['kdf'] as Map<String, dynamic>;
        final c = h.json['cipher'] as Map<String, dynamic>;
        final key = await deriveKey(
            password,
            KdfParams(
                salt: base64Decode(k['salt'] as String),
                memKiB: (k['memKiB'] as num).toInt(),
                iterations: (k['iterations'] as num).toInt(),
                parallelism: (k['parallelism'] as num).toInt()));
        zipped = await aead.decrypt(
            key, base64Decode(c['nonce'] as String), zipped);
      } on aead.WrongKey {
        throw const BackupWrongPassword();
      } on BackupError {
        rethrow;
      } catch (_) {
        throw const BackupDamaged('crypto header');
      }
    }
    final sha = (await Sha256().hash(zipped)).bytes.map(_hex).join();
    if (sha != h.json['payloadSha256']) throw const BackupDamaged('sha');
    try {
      final payload = jsonDecode(utf8.decode(gzip.decode(zipped)))
          as Map<String, dynamic>;
      if (payload['tables'] is! Map) throw const BackupDamaged('tables');
      return payload;
    } on BackupError {
      rethrow;
    } catch (_) {
      throw const BackupDamaged('payload');
    }
  }
}
