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
  ResetConfirmResult confirmResult = ResetConfirmResult.updated;
  final requested = <String>[];
  final confirmed = <({String email, String code, String password})>[];

  @override
  Future<ResetRequestResult> requestReset(String email) async {
    requested.add(email);
    return requestResult;
  }

  @override
  Future<ResetConfirmResult> confirmReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    confirmed.add((email: email, code: code, password: newPassword));
    return confirmResult;
  }
}
