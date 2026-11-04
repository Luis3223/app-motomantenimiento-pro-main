import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config.dart';
import 'password_reset_repository.dart';

/// Recuperación de contraseña con el enlace de Supabase Auth. El enlace abre
/// la app por [passwordResetRedirect]; `supabase_flutter` canjea el código y
/// emite `passwordRecovery`.
class SupabasePasswordReset implements PasswordResetRepository {
  final _links = StreamController<RecoveryLink>.broadcast();
  StreamSubscription<AuthState>? _authEvents;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Empieza a escuchar los enlaces. Se llama cuando Supabase ya está
  /// inicializado; los eventos anteriores se reciben igual porque el stream
  /// de Auth los repite.
  void attach() {
    _authEvents ??= _auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _links.add(RecoveryLink.opened);
        }
      },
      // Un enlace vencido o ya usado llega como error al canjear el código.
      onError: (Object error) {
        if (error is AuthException) _links.add(RecoveryLink.invalid);
      },
    );
  }

  @override
  Stream<RecoveryLink> get recoveryLinks => _links.stream;

  @override
  Future<ResetRequestResult> requestReset(String email) {
    return _guard(
      () async {
        await _auth.resetPasswordForEmail(
          email,
          redirectTo: passwordResetRedirect,
        );
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
  Future<PasswordUpdateResult> updatePassword(String newPassword) async {
    if (_auth.currentSession == null) return PasswordUpdateResult.expired;
    final result = await _guard(
      () async {
        await _auth.updateUser(UserAttributes(password: newPassword));
        return PasswordUpdateResult.updated;
      },
      offline: PasswordUpdateResult.offline,
      onAuthError: (error) => switch (error) {
        AuthWeakPasswordException() => PasswordUpdateResult.weakPassword,
        AuthSessionMissingException() => PasswordUpdateResult.expired,
        _ when error.code == 'same_password' =>
          PasswordUpdateResult.samePassword,
        _ => PasswordUpdateResult.failed,
      },
    );
    if (result == PasswordUpdateResult.updated ||
        result == PasswordUpdateResult.expired) {
      await cancelRecovery();
    }
    return result;
  }

  @override
  Future<void> cancelRecovery() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Sin red, la sesión local se descarta igualmente.
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
}
