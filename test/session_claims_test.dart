import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/auth/session_claims.dart';

String _jwt(Map<String, Object?> payload) {
  String part(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(payload)}.firma';
}

void main() {
  test('una sesión del enlace de recuperación se reconoce', () {
    final token = _jwt({
      'amr': [
        {'method': 'recovery', 'timestamp': 1},
      ],
    });

    expect(isRecoveryToken(token), isTrue);
  });

  test('una sesión con contraseña u OAuth no es de recuperación', () {
    final token = _jwt({
      'amr': [
        {'method': 'password', 'timestamp': 1},
        {'method': 'oauth', 'timestamp': 2},
      ],
    });

    expect(isRecoveryToken(token), isFalse);
  });

  test('un token mal formado no es de recuperación', () {
    expect(isRecoveryToken('no-es-un-jwt'), isFalse);
    expect(isRecoveryToken('a.%%%.c'), isFalse);
  });
}
