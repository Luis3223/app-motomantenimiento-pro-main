/// Resultado de pedir el enlace de recuperación.
///
/// No existe un estado de "cuenta no encontrada": Supabase responde igual
/// exista o no el correo, para no revelar quién es cliente (ADR 0005).
enum ResetRequestResult { sent, rateLimited, offline, failed }

/// Lo que pasó al abrir en el teléfono el enlace del correo.
enum RecoveryLink { opened, invalid }

/// Resultado de fijar la contraseña nueva tras abrir el enlace.
enum PasswordUpdateResult {
  updated,
  weakPassword,
  samePassword,
  expired,
  offline,
  failed,
}

abstract class PasswordResetRepository {
  /// Envía a [email] un enlace que abre la app en la pantalla de contraseña
  /// nueva.
  Future<ResetRequestResult> requestReset(String email);

  /// Emite cada vez que el usuario abre un enlace de recuperación.
  Stream<RecoveryLink> get recoveryLinks;

  /// Cambia la contraseña con la sesión temporal del enlace. Si termina (bien
  /// o con el enlace vencido) cierra esa sesión: el usuario entra después por
  /// el login normal.
  Future<PasswordUpdateResult> updatePassword(String newPassword);

  /// Descarta la sesión temporal si el usuario abandona el cambio.
  Future<void> cancelRecovery();
}
