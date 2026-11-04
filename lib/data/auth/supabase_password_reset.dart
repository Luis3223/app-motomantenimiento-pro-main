import 'package:supabase_flutter/supabase_flutter.dart';

import 'password_reset_repository.dart';

/// Recuperación de contraseña con el código de un solo uso de Supabase Auth.
/// La plantilla "Reset password" del proyecto debe incluir `{{ .Token }}`.
class SupabasePasswordReset implements PasswordResetRepository {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  Future<ResetRequestResult> requestReset(String email) {
    return _guard(
      () async {
        await _auth.resetPasswordForEmail(email);
        return ResetRequestResult.sent;
      },
      offline: ResetRequestResult.offline,
      onAuthError: (error) =>
          error.statusCode == '429' || (error.code ?? '').contains('rate_limit')
          ? ResetRequestResult.rateLimited
          : ResetRequestResult.failed,
    );
  }

  @override
  Future<ResetConfirmResult> confirmReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final verified = await _guard(
      () async {
        await _auth.verifyOTP(
          email: email,
          token: code,
          type: OtpType.recovery,
        );
        return null;
      },
      offline: ResetConfirmResult.offline,
      onAuthError: (_) => ResetConfirmResult.invalidCode,
    );
    if (verified != null) return verified;
    try {
      return await _guard(
        () async {
          await _auth.updateUser(UserAttributes(password: newPassword));
          return ResetConfirmResult.updated;
        },
        offline: ResetConfirmResult.offline,
        onAuthError: (error) => switch (error) {
          AuthWeakPasswordException() => ResetConfirmResult.weakPassword,
          _ when error.code == 'same_password' =>
            ResetConfirmResult.samePassword,
          _ => ResetConfirmResult.failed,
        },
      );
    } finally {
      await _closeRecoverySession();
    }
  }

  /// Traduce los fallos de red a [offline] y los de Auth con [onAuthError].
  Future<T> _guard<T>(
    Future<T> Function() action, {
    required T offline,
    required T Function(AuthException error) onAuthError,
  }) async {
    try {
      return await action();
    } on AuthRetryableFetchException {
      return offline;
    } on AuthException catch (error) {
      return onAuthError(error);
    } catch (_) {
      return offline;
    }
  }

  /// El código abre una sesión temporal; se cierra para que el usuario entre
  /// por el login normal con la contraseña nueva.
  Future<void> _closeRecoverySession() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Si no hay red, la sesión local se descarta igualmente.
    }
  }
}
