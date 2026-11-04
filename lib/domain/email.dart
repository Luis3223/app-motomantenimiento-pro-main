/// Reglas del correo electrónico compartidas por login, registro y
/// recuperación de contraseña.
String normalizeEmail(String email) => email.trim().toLowerCase();

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Indica si [email], ya normalizado, tiene forma de correo.
bool isValidEmail(String email) => _emailPattern.hasMatch(email);
