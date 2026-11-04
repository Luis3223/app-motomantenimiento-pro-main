import 'package:google_sign_in/google_sign_in.dart';

import '../../config.dart';

/// Falta el ID del cliente OAuth web en `lib/config.dart`.
class GoogleNotConfigured implements Exception {
  const GoogleNotConfigured();
}

/// Obtiene un ID token de Google con el selector de cuentas de Android.
abstract class GoogleCredentials {
  /// Devuelve el ID token, o `null` si el usuario cancela.
  Future<String?> idToken();

  Future<void> signOut();
}

class NativeGoogleCredentials implements GoogleCredentials {
  NativeGoogleCredentials({this.serverClientId = googleWebClientId});

  final String serverClientId;
  Future<void>? _initialized;

  GoogleSignIn get _google => GoogleSignIn.instance;

  Future<void> _ensureInitialized() {
    if (serverClientId.isEmpty) throw const GoogleNotConfigured();
    return _initialized ??= _google.initialize(serverClientId: serverClientId);
  }

  @override
  Future<String?> idToken() async {
    await _ensureInitialized();
    try {
      final account = await _google.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialized == null) return;
    await _google.signOut();
  }
}
