import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

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
            content: Text(c.feedbackMessage!, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
        c.clearFeedback();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // The background gradient matching the image
        decoration: BoxDecoration(
          color: context.bg1,
          gradient: context.isDarkMode ? const RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF2A0000), // Dark red glow at top
              Color(0xFF0D0A0A), // Blackish
              Color(0xFF000000),
            ],
            stops: [0.0, 0.5, 1.0],
          ) : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Abstract red lines for the background (approximated with simple shapes if needed, or just let gradient do the work)
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
                      BoxShadow(color: AppColors.strongRed.withValues(alpha: 0.15), blurRadius: 100),
                    ]
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
                      BoxShadow(color: AppColors.strongRed.withValues(alpha: 0.1), blurRadius: 100),
                    ]
                  ),
                ),
              ),
              
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      
                      // App Icon
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.strongRed.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Moto Mantenimiento Pro Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'MOTO ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            'MANTENIMIENTO',
                            style: TextStyle(
                              color: AppColors.strongRed,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
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
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 4.0,
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
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Center(
                        child: Text(
                          'TU MOTO, SIEMPRE EN BUENAS MANOS',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Welcome Text
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 28,
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
                      
                      const SizedBox(height: 30),

                      // Email Input
                      _buildInputForm(
                        context,
                        hint: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        controller: _email,
                      ),
                      
                      const SizedBox(height: 16),

                      // Password Input
                      _buildInputForm(
                        context,
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        controller: _password,
                        isPassword: true,
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      Container(
                        height: 55,
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
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
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

                      const SizedBox(height: 24),

                      // Create Account
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

                      const SizedBox(height: 30),

                      // Demo Credentials
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.cardColor, // Dark blueish black
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.email_outlined,
                                      color: AppColors.strongRed, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Demo: luis@gmail.com\n/ 123',
                                      style: TextStyle(
                                        color: context.textSecondary, 
                                        fontSize: 10,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: context.dividerColor,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person_outline,
                                      color: AppColors.strongRed, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Admin: admin@casaracing.com\n/ admin',
                                      style: TextStyle(
                                        color: context.textSecondary, 
                                        fontSize: 10,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTROL',
                            style: TextStyle(
                              color: context.textSecondary.withValues(alpha: 0.5),
                              fontSize: 8,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.stop, color: AppColors.strongRed, size: 6),
                          ),
                          Text(
                            'MANTENIMIENTO',
                            style: TextStyle(
                              color: context.textSecondary.withValues(alpha: 0.5),
                              fontSize: 8,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.stop, color: AppColors.strongRed, size: 6),
                          ),
                          Text(
                            'RENDIMIENTO',
                            style: TextStyle(
                              color: context.textSecondary.withValues(alpha: 0.5),
                              fontSize: 8,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm(
    BuildContext context, {
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor, // Dark input background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscure : false,
        style: TextStyle(color: context.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.strongRed, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
