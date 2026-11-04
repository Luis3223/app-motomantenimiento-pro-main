import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/auth_text_field.dart';
import '../view_models/new_password_view_model.dart';
import 'reset_form_scaffold.dart';

/// Ruta `/reset-password`, a la que lleva el enlace del correo. Espera un
/// [NewPasswordViewModel] en el árbol.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  Future<void> _save(NewPasswordViewModel vm) async {
    final updated = await vm.save(
      password: _password.text,
      confirmation: _confirmation.text,
    );
    if (!updated || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(NewPasswordViewModel.updatedMessage)),
    );
    context.go('/login');
  }

  Future<void> _leave(NewPasswordViewModel vm) async {
    await vm.cancel();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewPasswordViewModel>();
    return ResetFormScaffold(
      title: 'Contraseña nueva',
      intro: 'Elige la contraseña con la que vas a entrar desde ahora.',
      vm: vm,
      fields: [
        AuthTextField(
          hint: 'Contraseña nueva',
          icon: Icons.lock_outline,
          controller: _password,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: 'Repite la contraseña nueva',
          icon: Icons.lock_outline,
          controller: _confirmation,
          isPassword: true,
        ),
      ],
      submitLabel: 'Cambiar contraseña',
      onSubmit: () => _save(vm),
      onBack: () => _leave(vm),
    );
  }
}
