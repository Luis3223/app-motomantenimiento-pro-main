import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/auth_text_field.dart';
import '../view_models/password_reset_view_model.dart';
import 'reset_form_scaffold.dart';

/// Ruta `/forgot-password`. Espera un [PasswordResetViewModel] en el árbol.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PasswordResetViewModel>();
    return ResetFormScaffold(
      title: 'Recuperar contraseña',
      intro:
          'Te enviaremos un enlace a tu correo. Ábrelo en este teléfono para '
          'elegir una contraseña nueva.',
      vm: vm,
      fields: [
        AuthTextField(
          hint: 'Correo electrónico',
          icon: Icons.email_outlined,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
      submitLabel: vm.linkSent ? 'Enviar a este correo' : 'Enviar enlace',
      onSubmit: () => vm.requestLink(_email.text),
      onBack: () => context.go('/login'),
      actions: [
        if (vm.linkSent)
          TextButton(
            onPressed: vm.busy ? null : vm.resendLink,
            child: const Text(
              'Reenviar enlace',
              style: TextStyle(color: AppColors.strongRed),
            ),
          ),
      ],
    );
  }
}
