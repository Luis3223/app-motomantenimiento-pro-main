import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _model;
  late final TextEditingController _plate;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = context.read<AppController>().currentUser;
    _name = TextEditingController(text: user?.name ?? '');
    _model = TextEditingController(text: user?.bikeModel ?? '');
    _plate = TextEditingController(text: user?.bikePlate ?? '');
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _name.dispose();
      _model.dispose();
      _plate.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final c = context.read<AppController>();
    final user = c.currentUser;
    if (user == null) return;
    await c.handleProfileUpdate(
      user.copyWith(
        name: _name.text.trim(),
        bikeModel: _model.text.trim(),
        bikePlate: _plate.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppController>().currentUser;

    return Scaffold(
      backgroundColor: context.bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.bg2, context.bg1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: context.textPrimary, size: 32),
                      onPressed: () => context.go('/garage'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mi Perfil', style: TextStyle(color: context.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            'Configura tu cuenta y mantén tus datos al día.',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, spreadRadius: 0),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withOpacity(0.1),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Icon(Icons.person, color: Colors.red, size: 32),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Usuario',
                                  style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(color: context.textSecondary, fontSize: 14),
                                ),
                                if (user?.isAdmin == true)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Administrador',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Forms
                    _buildTextField(label: 'Nombre Completo', controller: _name, icon: Icons.person_outline),
                    SizedBox(height: 16),
                    _buildTextField(label: 'Modelo de Moto', controller: _model, icon: Icons.two_wheeler),
                    SizedBox(height: 16),
                    _buildTextField(label: 'Placa', controller: _plate, icon: Icons.confirmation_number_outlined),
                    SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _save,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: context.textPrimary),
                            SizedBox(width: 8),
                            Text('Guardar Cambios', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Settings
                    Text('Ajustes de la App', style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(context.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: context.textPrimary),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Modo Oscuro',
                              style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Switch(
                            value: context.isDarkMode,
                            activeColor: Colors.red,
                            onChanged: (_) => context.read<AppController>().toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    _buildSettingButton(
                      icon: Icons.list_alt,
                      label: 'Tipos de Servicios',
                      onTap: () => context.go('/manage-services'),
                    ),
                    SizedBox(height: 12),
                    _buildSettingButton(
                      icon: Icons.support_agent,
                      label: 'Ayuda y Soporte',
                      onTap: () {}, // WhatsApp integration or help page
                    ),
                    SizedBox(height: 12),
                    _buildSettingButton(
                      icon: Icons.logout,
                      label: 'Cerrar Sesión',
                      isDestructive: true,
                      onTap: () {
                        context.read<AppController>().handleLogout();
                        context.go('/login');
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red),
            filled: true,
            fillColor: context.cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingButton({required IconData icon, required String label, required VoidCallback onTap, bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : context.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (!isDestructive) Icon(Icons.chevron_right, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
