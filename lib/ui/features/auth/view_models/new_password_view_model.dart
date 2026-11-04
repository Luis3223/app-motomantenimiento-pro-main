import '../../../../data/auth/password_reset_repository.dart';
import 'password_reset_view_model.dart';

/// Ruta `/reset-password`: fija la contraseña nueva tras abrir el enlace.
class NewPasswordViewModel extends ResetFormViewModel {
  NewPasswordViewModel(this._repository);

  /// Supabase rechaza contraseñas de menos de 6 caracteres.
  static const minPasswordLength = 6;

  static const updatedMessage =
      'Contraseña actualizada. Inicia sesión con la nueva.';

  static const _weakPassword =
      'La contraseña debe tener al menos $minPasswordLength caracteres.';

  final PasswordResetRepository _repository;

  /// Devuelve `true` si la contraseña cambió; la vista vuelve al login.
  Future<bool> save({
    required String password,
    required String confirmation,
  }) async {
    if (password.length < minPasswordLength) {
      error(_weakPassword);
      return false;
    }
    if (password != confirmation) {
      error('Las contraseñas no coinciden.');
      return false;
    }
    final result = await whileBusy(() => _repository.updatePassword(password));
    if (result == PasswordUpdateResult.updated) {
      info(updatedMessage);
      return true;
    }
    error(switch (result) {
      PasswordUpdateResult.weakPassword => _weakPassword,
      PasswordUpdateResult.samePassword =>
        'La contraseña nueva debe ser distinta de la anterior.',
      PasswordUpdateResult.expired =>
        'El enlace venció. Pide uno nuevo desde el inicio de sesión.',
      PasswordUpdateResult.offline =>
        'Sin conexión no se puede cambiar la contraseña.',
      _ => 'No se pudo cambiar la contraseña. Inténtalo de nuevo.',
    });
    return false;
  }

  /// El usuario abandona el cambio: se descarta la sesión del enlace.
  Future<void> cancel() => _repository.cancelRecovery();
}
