import 'package:flutter/foundation.dart';

import '../../../../data/auth/password_reset_repository.dart';
import '../../../../domain/email.dart';

enum PasswordResetStep { email, code }

/// Mensaje de estado bajo el formulario.
typedef ResetNotice = ({String text, bool isError});

/// Recuperación de contraseña en dos pasos: pedir el código al correo y
/// fijar la contraseña nueva con ese código.
class PasswordResetViewModel extends ChangeNotifier {
  PasswordResetViewModel(this._repository);

  /// Supabase rechaza contraseñas de menos de 6 caracteres.
  static const minPasswordLength = 6;

  static const updatedMessage =
      'Contraseña actualizada. Inicia sesión con la nueva.';

  static const _weakPassword =
      'La contraseña debe tener al menos $minPasswordLength caracteres.';

  static final _codePattern = RegExp(r'^\d{6,10}$');

  final PasswordResetRepository _repository;

  PasswordResetStep step = PasswordResetStep.email;
  String email = '';
  bool busy = false;
  ResetNotice? notice;

  Future<void> requestCode(String rawEmail) async {
    final normalized = normalizeEmail(rawEmail);
    if (!isValidEmail(normalized)) {
      return _error('Ingresa un correo electrónico válido.');
    }
    email = normalized;
    await _send();
  }

  Future<void> resendCode() => _send();

  Future<void> _send() async {
    final result = await _whileBusy(() => _repository.requestReset(email));
    if (result == ResetRequestResult.sent) {
      step = PasswordResetStep.code;
      return _info(
        'Si $email tiene una cuenta, te enviamos un código. '
        'Revisa también la carpeta de spam.',
      );
    }
    _error(switch (result) {
      ResetRequestResult.rateLimited =>
        'Ya pediste varios códigos. Espera unos minutos e inténtalo de nuevo.',
      ResetRequestResult.offline =>
        'Sin conexión no se puede enviar el código.',
      _ => 'No se pudo enviar el código. Inténtalo de nuevo.',
    });
  }

  /// Devuelve `true` si la contraseña cambió; la vista vuelve al login.
  Future<bool> confirm({
    required String code,
    required String password,
    required String confirmation,
  }) async {
    final trimmedCode = code.trim();
    final invalid = !_codePattern.hasMatch(trimmedCode)
        ? 'Escribe el código numérico que llegó a tu correo.'
        : password.length < minPasswordLength
        ? _weakPassword
        : password != confirmation
        ? 'Las contraseñas no coinciden.'
        : null;
    if (invalid != null) {
      _error(invalid);
      return false;
    }
    final result = await _whileBusy(
      () => _repository.confirmReset(
        email: email,
        code: trimmedCode,
        newPassword: password,
      ),
    );
    if (result == ResetConfirmResult.updated) {
      _info(updatedMessage);
      return true;
    }
    _error(switch (result) {
      ResetConfirmResult.invalidCode =>
        'El código no es válido o ya venció. Pide uno nuevo.',
      ResetConfirmResult.weakPassword => _weakPassword,
      ResetConfirmResult.samePassword =>
        'La contraseña nueva debe ser distinta de la anterior.',
      ResetConfirmResult.offline =>
        'Sin conexión no se puede cambiar la contraseña.',
      _ => 'No se pudo cambiar la contraseña. Inténtalo de nuevo.',
    });
    return false;
  }

  void changeEmail() {
    step = PasswordResetStep.email;
    notice = null;
    notifyListeners();
  }

  Future<T> _whileBusy<T>(Future<T> Function() action) async {
    busy = true;
    notice = null;
    notifyListeners();
    try {
      return await action();
    } finally {
      busy = false;
    }
  }

  void _info(String text) => _show((text: text, isError: false));

  void _error(String text) => _show((text: text, isError: true));

  void _show(ResetNotice value) {
    notice = value;
    notifyListeners();
  }
}
