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

/// El usuario cerró el selector de cuentas sin elegir ninguna.
class AuthCancelled extends AuthOutcome {
  const AuthCancelled();
}

/// El proveedor no está configurado en esta compilación.
class AuthUnavailable extends AuthOutcome {
  const AuthUnavailable();
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

  /// Inicia sesión o crea la cuenta con Google. Supabase enlaza la identidad
  /// con la cuenta que ya tenga el mismo correo verificado.
  Future<AuthOutcome> signInWithGoogle();

  Future<void> signOut();
}
