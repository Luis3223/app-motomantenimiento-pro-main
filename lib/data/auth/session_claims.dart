import 'dart:convert';

/// Indica si el JWT de Supabase viene de un enlace de recuperación de
/// contraseña (claim `amr` con método `recovery`). Esa sesión solo sirve para
/// fijar la contraseña nueva; no debe abrir la app.
bool isRecoveryToken(String accessToken) {
  final parts = accessToken.split('.');
  if (parts.length != 3) return false;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final amr = payload is Map ? payload['amr'] : null;
    if (amr is! List) return false;
    return amr.any((entry) => entry is Map && entry['method'] == 'recovery');
  } on FormatException {
    return false;
  }
}
