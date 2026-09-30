import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hash con sal de contraseñas (PBKDF2-HMAC-SHA256).
///
/// El resultado es `pbkdf2$<iteraciones>$<sal>$<hash>` (base64), de modo que
/// se puede subir el número de iteraciones sin invalidar los hashes viejos.
class PasswordHasher {
  const PasswordHasher({this.iterations = defaultIterations});

  static const defaultIterations = 60000;
  static const _prefix = 'pbkdf2';
  static const _saltLength = 16;

  final int iterations;

  /// Indica si [stored] ya es un hash de este formato (y no texto plano).
  static bool isHashed(String stored) => stored.startsWith('$_prefix\$');

  String hash(String password, {Uint8List? salt}) {
    final s = salt ?? _randomSalt();
    final digest = _pbkdf2(utf8.encode(password), s, iterations);
    return '$_prefix\$$iterations\$${base64.encode(s)}\$${base64.encode(digest)}';
  }

  bool verify(String password, String stored) {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _prefix) return false;
    final rounds = int.tryParse(parts[1]);
    if (rounds == null || rounds < 1) return false;
    try {
      final expected = base64.decode(parts[3]);
      final actual = _pbkdf2(
        utf8.encode(password),
        base64.decode(parts[2]),
        rounds,
      );
      return _constantTimeEquals(expected, actual);
    } on FormatException {
      return false;
    }
  }

  static Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_saltLength, (_) => random.nextInt(256)),
    );
  }

  /// PBKDF2 de un solo bloque (32 bytes, el tamaño de SHA-256).
  static Uint8List _pbkdf2(List<int> password, List<int> salt, int rounds) {
    final hmac = Hmac(sha256, password);
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = Uint8List.fromList(u);
    for (var i = 1; i < rounds; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
