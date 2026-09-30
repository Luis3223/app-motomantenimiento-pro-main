import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/security/password_hasher.dart';

void main() {
  // Pocas iteraciones: los tests no necesitan el coste de producción.
  const hasher = PasswordHasher(iterations: 10);

  test('el hash no contiene la contraseña en texto plano', () {
    final stored = hasher.hash('secreta123');

    expect(stored, isNot(contains('secreta123')));
    expect(PasswordHasher.isHashed(stored), isTrue);
  });

  test('verifica la contraseña correcta y rechaza la incorrecta', () {
    final stored = hasher.hash('secreta123');

    expect(hasher.verify('secreta123', stored), isTrue);
    expect(hasher.verify('otra', stored), isFalse);
  });

  test('la misma contraseña produce hashes distintos (sal aleatoria)', () {
    expect(hasher.hash('123'), isNot(hasher.hash('123')));
  });

  test('verifica hashes creados con otro número de iteraciones', () {
    final stored = const PasswordHasher(iterations: 5).hash('abc');

    expect(hasher.verify('abc', stored), isTrue);
  });

  test('un valor en texto plano o mal formado nunca verifica', () {
    expect(PasswordHasher.isHashed('123'), isFalse);
    expect(hasher.verify('123', '123'), isFalse);
    expect(hasher.verify('123', r'pbkdf2$x$y$z'), isFalse);
    expect(hasher.verify('123', r'pbkdf2$10$!!$!!'), isFalse);
  });

  test('coincide con el vector de prueba PBKDF2-HMAC-SHA256 (RFC 7914)', () {
    // P = "password", S = "salt", c = 1, dkLen = 32.
    const expectedHex =
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b';
    final expected = List.generate(
      32,
      (i) => int.parse(expectedHex.substring(i * 2, i * 2 + 2), radix: 16),
    );

    final stored = const PasswordHasher(iterations: 1)
        .hash('password', salt: Uint8List.fromList('salt'.codeUnits));

    expect(base64.decode(stored.split(r'$')[3]), expected);
  });
}
