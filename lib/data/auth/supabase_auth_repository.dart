import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';
import 'google_credentials.dart';
import 'session_claims.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({GoogleCredentials? google})
    : _google = google ?? NativeGoogleCredentials();

  final GoogleCredentials _google;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<AuthIdentity?> currentSession() async {
    final session = _client.auth.currentSession;
    if (session == null || isRecoveryToken(session.accessToken)) return null;
    final user = session.user;
    return AuthIdentity(userId: user.id, email: user.email ?? '');
  }

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) {
    return _run(() async {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _signedIn(response.user, email);
    });
  }

  @override
  Future<AuthOutcome> signUp({
    required String email,
    required String password,
  }) {
    return _run(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return _signedIn(response.user, email);
    });
  }

  @override
  Future<AuthOutcome> signInWithGoogle() async {
    final String? idToken;
    try {
      idToken = await _google.idToken();
    } on GoogleNotConfigured {
      return const AuthUnavailable();
    } on GoogleSignInException catch (error) {
      return error.code == GoogleSignInExceptionCode.clientConfigurationError ||
              error.code == GoogleSignInExceptionCode.providerConfigurationError
          ? const AuthUnavailable()
          : const AuthFailed();
    } catch (_) {
      return const AuthOffline();
    }
    if (idToken == null) return const AuthCancelled();
    return _run(() async {
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken!,
      );
      return _signedIn(response.user, '');
    });
  }

  @override
  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {
      // Sin sesión de Google no hay nada que cerrar.
    }
    if (_client.auth.currentSession == null) return;
    await _client.auth.signOut();
  }

  Future<AuthOutcome> _run(Future<AuthOutcome> Function() action) async {
    try {
      return await action();
    } on AuthRetryableFetchException {
      return const AuthOffline();
    } on AuthException catch (error) {
      return AuthFailed(alreadyRegistered: _alreadyRegistered(error));
    } catch (_) {
      return const AuthOffline();
    }
  }

  AuthOutcome _signedIn(User? user, String email) {
    if (user == null || _client.auth.currentSession == null) {
      return const AuthFailed();
    }
    return AuthSignedIn(userId: user.id, email: user.email ?? email);
  }

  bool _alreadyRegistered(AuthException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();
    return code == 'user_already_exists' || message.contains('already');
  }
}
