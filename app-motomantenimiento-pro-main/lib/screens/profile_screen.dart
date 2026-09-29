import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.strongRed, AppColors.darkRed],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.two_wheeler, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (user?.isAdmin == true)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Administrador',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _model,
            decoration: const InputDecoration(labelText: 'Modelo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _plate,
            decoration: const InputDecoration(labelText: 'Placa'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              context.read<AppController>().handleLogout();
              context.go('/login');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
