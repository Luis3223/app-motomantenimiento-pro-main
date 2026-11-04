import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_theme.dart';
import '../../../../widgets/auth_text_field.dart';
import '../view_models/password_reset_view_model.dart';

/// Ruta `/forgot-password`. Espera un [PasswordResetViewModel] en el árbol.
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  Future<void> _confirm(PasswordResetViewModel vm) async {
    final updated = await vm.confirm(
      code: _code.text,
      password: _password.text,
      confirmation: _confirmation.text,
    );
    if (!updated || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(PasswordResetViewModel.updatedMessage)),
    );
    context.go('/login');
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PasswordResetViewModel>();
    final onCode = vm.step == PasswordResetStep.code;
    return Scaffold(
      backgroundColor: context.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Volver al inicio de sesión',
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => context.go('/login'),
        ),
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(color: context.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                onCode
                    ? 'Escribe el código que enviamos a ${vm.email} y elige '
                          'una contraseña nueva.'
                    : 'Te enviaremos un código a tu correo para que elijas '
                          'una contraseña nueva.',
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              if (onCode) ...[
                AuthTextField(
                  hint: 'Código de verificación',
                  icon: Icons.pin_outlined,
                  controller: _code,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
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
              ] else
                AuthTextField(
                  hint: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
              if (vm.notice case final notice?) ...[
                const SizedBox(height: 16),
                _NoticeBox(notice: notice),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                ),
                onPressed: vm.busy
                    ? null
                    : () => onCode ? _confirm(vm) : vm.requestCode(_email.text),
                child: vm.busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        onCode ? 'Cambiar contraseña' : 'Enviar código',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (onCode) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: vm.busy ? null : vm.resendCode,
                  child: const Text(
                    'Reenviar código',
                    style: TextStyle(color: AppColors.strongRed),
                  ),
                ),
                TextButton(
                  onPressed: vm.busy ? null : vm.changeEmail,
                  child: Text(
                    'Usar otro correo',
                    style: TextStyle(color: context.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.notice});

  final ResetNotice notice;

  @override
  Widget build(BuildContext context) {
    final color = notice.isError ? AppColors.strongRed : context.textPrimary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notice.isError ? AppColors.strongRed : context.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            notice.isError
                ? Icons.error_outline
                : Icons.mark_email_read_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notice.text,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
