import 'dart:async';

import 'package:motomantenimiento_pro/data/auth/auth_repository.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final accounts = <String, ({String userId, String password})>{};
  AuthIdentity? session;

  /// Lo que devuelve el selector de Google en el próximo intento.
  AuthOutcome googleOutcome = const AuthCancelled();
  int googleCalls = 0;

  @override
  Future<AuthIdentity?> currentSession() async => session;

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    final account = accounts[email];
    if (account == null || account.password != password) {
      return const AuthFailed();
    }
    session = AuthIdentity(userId: account.userId, email: email);
    return AuthSignedIn(userId: account.userId, email: email);
  }

  @override
  Future<AuthOutcome> signUp({
    required String email,
    required String password,
  }) async {
    if (accounts.containsKey(email)) {
      return const AuthFailed(alreadyRegistered: true);
    }
    final userId = 'user-$email';
    accounts[email] = (userId: userId, password: password);
    session = AuthIdentity(userId: userId, email: email);
    return AuthSignedIn(userId: userId, email: email);
  }

  @override
  Future<AuthOutcome> signInWithGoogle() async {
    googleCalls++;
    final outcome = googleOutcome;
    if (outcome is AuthSignedIn) {
      session = AuthIdentity(userId: outcome.userId, email: outcome.email);
    }
    return outcome;
  }

  @override
  Future<void> signOut() async => session = null;
}

class FakePasswordReset implements PasswordResetRepository {
  ResetRequestResult requestResult = ResetRequestResult.sent;
  PasswordUpdateResult updateResult = PasswordUpdateResult.updated;
  final requested = <String>[];
  final updatedPasswords = <String>[];
  int cancelCalls = 0;
  final _links = StreamController<RecoveryLink>.broadcast();

  /// Simula abrir en el teléfono el enlace del correo.
  void openLink(RecoveryLink link) => _links.add(link);

  @override
  Stream<RecoveryLink> get recoveryLinks => _links.stream;

  @override
  Future<ResetRequestResult> requestReset(String email) async {
    requested.add(email);
    return requestResult;
  }

  @override
  Future<PasswordUpdateResult> updatePassword(String newPassword) async {
    updatedPasswords.add(newPassword);
    return updateResult;
  }

  @override
  Future<void> cancelRecovery() async => cancelCalls++;
}
