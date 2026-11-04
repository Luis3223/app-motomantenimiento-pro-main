import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

/// Escala vertical del login respecto a un alto de diseño de referencia.
class _LoginMetrics {
  _LoginMetrics(double height)
    : scale = (height / _designHeight).clamp(0.55, 1.0);

  static const double _designHeight = 880;

  final double scale;

  double get topGap => 28 * scale;
  double get iconSize => 140 * scale;
  double get afterIcon => 18 * scale;
  double get afterBrand => 14 * scale;
  double get afterSubtitle => 28 * scale;
  double get afterWelcome => 22 * scale;
  double get fieldGap => 14 * scale;
  double get afterForgot => 4 * scale;
  double get afterButton => 16 * scale;
  double get footerGap => 16 * scale;
  double get buttonHeight => (52 * scale).clamp(44.0, 55.0);
  double get titleSize => (24 * scale).clamp(16.0, 24.0);
  double get welcomeSize => (26 * scale).clamp(18.0, 28.0);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    final c = context.read<AppController>();
    final success = await c.handleLogin(_email.text, _password.text);

    if (!mounted) return;

    if (success) {
      context.go('/garage');
    } else {
      setState(() => _loading = false);
      if (c.feedbackMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              c.feedbackMessage!,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        c.clearFeedback();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          color: context.bg1,
          gradient: context.isDarkMode
              ? const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    Color(0xFF2A0000),
                    Color(0xFF0D0A0A),
                    Color(0xFF000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                )
              : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.strongRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.strongRed.withValues(alpha: 0.15),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.strongRed.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.strongRed.withValues(alpha: 0.1),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  // La escala usa el alto sin teclado: abrirlo no reorganiza
                  // la pantalla, solo permite desplazarla.
                  final metrics = _LoginMetrics(
                    constraints.maxHeight + keyboardHeight,
                  );
                  // El árbol es el mismo con y sin teclado. Si cambiara de
                  // padre, Flutter recrearía los campos y el enfocado perdería
                  // el foco, lo que cierra el teclado.
                  return SingleChildScrollView(
                    physics: keyboardHeight > 0
                        ? null
                        : const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildBody(context, metrics),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, _LoginMetrics m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: m.topGap),
        Center(
          child: Container(
            width: m.iconSize,
            height: m.iconSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.strongRed.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/icon.png', fit: BoxFit.cover),
            ),
          ),
        ),
        SizedBox(height: m.afterIcon),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MOTO ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: m.titleSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'MANTENIMIENTO',
                style: TextStyle(
                  color: AppColors.strongRed,
                  fontSize: m.titleSize,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 30,
              color: AppColors.strongRed.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Text(
              'PRO',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: (20 * m.scale).clamp(14.0, 20.0),
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 1,
              width: 30,
              color: AppColors.strongRed.withValues(alpha: 0.5),
            ),
          ],
        ),
        SizedBox(height: m.afterBrand),
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'TU MOTO, SIEMPRE EN BUENAS MANOS',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: m.afterSubtitle),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: m.welcomeSize,
              fontWeight: FontWeight.w900,
              color: context.textPrimary,
            ),
            children: const [
              TextSpan(text: 'Bienvenido '),
              TextSpan(
                text: 'de nuevo',
                style: TextStyle(color: AppColors.strongRed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Inicia sesión para continuar con tu cuenta',
          style: TextStyle(color: context.textSecondary, fontSize: 13),
        ),
        SizedBox(height: m.afterWelcome),
        AuthTextField(
          hint: 'Correo electrónico',
          icon: Icons.email_outlined,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: m.fieldGap),
        AuthTextField(
          hint: 'Contraseña',
          icon: Icons.lock_outline,
          controller: _password,
          isPassword: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/forgot-password'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
          ),
        ),
        SizedBox(height: m.afterForgot),
        Container(
          height: m.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF2A2A), Color(0xFFA60000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.strongRed.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: m.fieldGap),
        GoogleSignInButton(height: m.buttonHeight),
        SizedBox(height: m.afterButton),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 60,
              color: AppColors.strongRed.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context.go('/register'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Crear cuenta',
                style: TextStyle(
                  color: AppColors.strongRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 1,
              width: 60,
              color: AppColors.strongRed.withValues(alpha: 0.3),
            ),
          ],
        ),
        SizedBox(height: m.footerGap),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CONTROL',
                style: TextStyle(
                  color: context.textSecondary.withValues(alpha: 0.5),
                  fontSize: 8,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.stop, color: AppColors.strongRed, size: 6),
              ),
              Text(
                'MANTENIMIENTO',
                style: TextStyle(
                  color: context.textSecondary.withValues(alpha: 0.5),
                  fontSize: 8,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.stop, color: AppColors.strongRed, size: 6),
              ),
              Text(
                'RENDIMIENTO',
                style: TextStyle(
                  color: context.textSecondary.withValues(alpha: 0.5),
                  fontSize: 8,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: m.footerGap),
      ],
    );
  }
}
