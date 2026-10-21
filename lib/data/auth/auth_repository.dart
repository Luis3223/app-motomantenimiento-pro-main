/// Resultado de un intento de autenticación contra Supabase.
sealed class AuthOutcome {
  const AuthOutcome();
}

class AuthSignedIn extends AuthOutcome {
  const AuthSignedIn({required this.userId, required this.email});

  final String userId;
  final String email;
}

class AuthFailed extends AuthOutcome {
  const AuthFailed({this.alreadyRegistered = false});

  final bool alreadyRegistered;
}

class AuthOffline extends AuthOutcome {
  const AuthOffline();
}

class AuthIdentity {
  const AuthIdentity({required this.userId, required this.email});

  final String userId;
  final String email;
}

abstract class AuthRepository {
  Future<AuthIdentity?> currentSession();

  Future<AuthOutcome> signIn({required String email, required String password});

  Future<AuthOutcome> signUp({required String email, required String password});

  Future<void> signOut();
}
