import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<AuthIdentity?> currentSession() async {
    final session = _client.auth.currentSession;
    final user = session?.user;
    if (user == null) return null;
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
  Future<void> signOut() async {
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
    if (user == null) return const AuthFailed();
    if (_client.auth.currentSession == null) {
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
