/// Resultado de pedir el código de recuperación.
///
/// No existe un estado de "cuenta no encontrada": Supabase responde igual
/// exista o no el correo, para no revelar quién es cliente (ADR 0005).
enum ResetRequestResult { sent, rateLimited, offline, failed }

/// Resultado de fijar la contraseña nueva con el código recibido.
enum ResetConfirmResult {
  updated,
  invalidCode,
  weakPassword,
  samePassword,
  offline,
  failed,
}

abstract class PasswordResetRepository {
  /// Envía un código de recuperación a [email].
  Future<ResetRequestResult> requestReset(String email);

  /// Verifica [code] y cambia la contraseña. Al terminar no deja sesión
  /// abierta: el usuario entra después con la contraseña nueva.
  Future<ResetConfirmResult> confirmReset({
    required String email,
    required String code,
    required String newPassword,
  });
}
