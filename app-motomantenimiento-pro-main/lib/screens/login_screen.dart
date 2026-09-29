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
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final controller = context.read<AppController>();
    await controller.handleLogin(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A0000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/icon.png', height: 160),
                  const SizedBox(height: 12),
                  const Text(
                    'TU MOTO, SIEMPRE EN BUENAS MANOS',
                    style: TextStyle(
                      color: Colors.white54, 
                      fontSize: 10, 
                      letterSpacing: 2, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Welcome Text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        children: [
                          TextSpan(text: 'Bienvenido '),
                          TextSpan(text: 'de nuevo', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Inicia sesión para continuar con tu cuenta',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  _buildTextField(
                    controller: _email,
                    hint: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  _buildTextField(
                    controller: _password,
                    hint: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: Colors.redAccent.withOpacity(0.5),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Iniciar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.red.withOpacity(0.3), thickness: 1)),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Crear cuenta', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: Colors.red.withOpacity(0.3), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Demo Credentials Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.email_outlined, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Demo: luis@gmail.com\n/ 123', 
                                  style: TextStyle(color: Colors.white70, fontSize: 10)
                                )
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1, 
                          height: 30, 
                          color: Colors.white12, 
                          margin: EdgeInsets.symmetric(horizontal: 8)
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.person_outline, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Admin: admin@casaracing.com\n/ admin', 
                                  style: TextStyle(color: Colors.white70, fontSize: 10)
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Footer text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 30, height: 1, color: Colors.red.withOpacity(0.5)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'CONTROL  ·  MANTENIMIENTO  ·  RENDIMIENTO',
                          style: TextStyle(
                            color: Colors.white54, 
                            fontSize: 8, 
                            letterSpacing: 1.5, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(width: 30, height: 1, color: Colors.red.withOpacity(0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.red),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
