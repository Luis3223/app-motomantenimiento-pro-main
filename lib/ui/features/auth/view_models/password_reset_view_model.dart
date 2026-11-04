import 'package:flutter/foundation.dart';

import '../../../../data/auth/password_reset_repository.dart';
import '../../../../domain/email.dart';

/// Mensaje de estado bajo el formulario.
typedef ResetNotice = ({String text, bool isError});

/// Estado compartido de las pantallas de recuperación: ocupado y aviso.
abstract class ResetFormViewModel extends ChangeNotifier {
  bool busy = false;
  ResetNotice? notice;

  @protected
  Future<T> whileBusy<T>(Future<T> Function() action) async {
    busy = true;
    notice = null;
    notifyListeners();
    try {
      return await action();
    } finally {
      busy = false;
    }
  }

  @protected
  void info(String text) => _show((text: text, isError: false));

  @protected
  void error(String text) => _show((text: text, isError: true));

  void _show(ResetNotice value) {
    notice = value;
    notifyListeners();
  }
}

/// Ruta `/forgot-password`: pide el enlace de recuperación al correo.
class PasswordResetViewModel extends ResetFormViewModel {
  PasswordResetViewModel(this._repository);

  final PasswordResetRepository _repository;

  String email = '';

  /// Ya se envió un enlace: la vista ofrece reenviarlo.
  bool linkSent = false;

  Future<void> requestLink(String rawEmail) async {
    final normalized = normalizeEmail(rawEmail);
    if (!isValidEmail(normalized)) {
      return error('Ingresa un correo electrónico válido.');
    }
    email = normalized;
    await resendLink();
  }

  Future<void> resendLink() async {
    final result = await whileBusy(() => _repository.requestReset(email));
    if (result == ResetRequestResult.sent) {
      linkSent = true;
      return info(
        'Si $email tiene una cuenta, te enviamos un enlace. Ábrelo en este '
        'teléfono para elegir la contraseña nueva. Revisa también el spam.',
      );
    }
    error(switch (result) {
      ResetRequestResult.rateLimited =>
        'Ya pediste varios enlaces. Espera unos minutos e inténtalo de nuevo.',
      ResetRequestResult.offline =>
        'Sin conexión no se puede enviar el enlace.',
      _ => 'No se pudo enviar el enlace. Inténtalo de nuevo.',
    });
  }
}
