import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _title = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final recent = c.allServices.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/history'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Push simulado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _message,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Mensaje'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (_title.text.trim().isEmpty || _message.text.trim().isEmpty) {
                return;
              }
              c.adminPushNotification(_title.text.trim(), _message.text.trim());
              _title.clear();
              _message.clear();
            },
            child: const Text('Enviar alerta'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Usuarios',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final u in c.allUsers)
            Card(
              child: ListTile(
                title: Text(u.name),
                subtitle: Text('${u.email} · ${u.bikeModel} · ${u.bikePlate}'),
                trailing: u.isAdmin
                    ? const Chip(
                        label: Text('Admin', style: TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.strongRed,
                      )
                    : null,
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Últimos 5 servicios globales',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final s in recent)
            Card(
              child: ListTile(
                title: Text(s.type),
                subtitle: Text('${s.userId} · ${s.date} · ${s.mileage} km'),
              ),
            ),
        ],
      ),
    );
  }
}
