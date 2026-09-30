import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _year = TextEditingController();
  final _vin = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _model.dispose();
    _plate.dispose();
    _year.dispose();
    _vin.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    final c = context.read<AppController>();

    final success = await c.handleRegister(
      name: _name.text,
      email: _email.text,
      pass: _password.text,
      model: _model.text,
      plate: _plate.text,
      year: _year.text,
      vin: _vin.text,
    );

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
    return Scaffold(
      body: Container(
        // The background gradient matching the login screen
        decoration: BoxDecoration(
          color: context.bg1,
          gradient: context.isDarkMode
              ? const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    Color(0xFF2A0000), // Dark red glow at top
                    Color(0xFF0D0A0A), // Blackish
                    Color(0xFF000000),
                  ],
                  stops: [0.0, 0.5, 1.0],
                )
              : null,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Abstract red lines for the background
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

              Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back, color: context.textPrimary),
                      onPressed: () => context.go('/login'),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // App Icon
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.strongRed.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
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

                            // Title
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: context.textPrimary,
                                  ),
                                  children: const [
                                    TextSpan(text: 'Crear '),
                                    TextSpan(
                                      text: 'Cuenta',
                                      style: TextStyle(
                                        color: AppColors.strongRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Únete a Moto Mantenimiento Pro',
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Name Input
                            _buildInputForm(
                              context,
                              hint: 'Nombre completo',
                              icon: Icons.person_outline,
                              controller: _name,
                            ),

                            const SizedBox(height: 16),

                            // Email Input
                            _buildInputForm(
                              context,
                              hint: 'Correo electrónico',
                              icon: Icons.email_outlined,
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
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

                            const SizedBox(height: 16),

                            // Bike Model Input
                            _buildInputForm(
                              context,
                              hint: 'Modelo de tu Moto (ej. Yamaha R6)',
                              icon: Icons.two_wheeler_outlined,
                              controller: _model,
                            ),

                            const SizedBox(height: 16),

                            // Plate Input
                            _buildInputForm(
                              context,
                              hint: 'Placa de la Moto (ej. XYZ-123)',
                              icon: Icons.tag_outlined,
                              controller: _plate,
                            ),

                            const SizedBox(height: 16),

                            // Year Input (optional)
                            _buildInputForm(
                              context,
                              hint: 'Año de la moto (opcional)',
                              icon: Icons.calendar_today_outlined,
                              controller: _year,
                              keyboardType: TextInputType.number,
                            ),

                            const SizedBox(height: 16),

                            // VIN Input (optional)
                            _buildInputForm(
                              context,
                              hint: 'VIN (opcional)',
                              icon: Icons.confirmation_number_outlined,
                              controller: _vin,
                            ),

                            const SizedBox(height: 32),

                            // Register Button
                            Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF2A2A),
                                    Color(0xFFA60000),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.strongRed.withValues(
                                      alpha: 0.4,
                                    ),
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
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Registrarse',
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
                                  color: AppColors.strongRed.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Iniciar sesión',
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
                                  color: AppColors.strongRed.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
