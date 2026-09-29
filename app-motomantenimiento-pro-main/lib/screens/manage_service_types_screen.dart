import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class ManageServiceTypesScreen extends StatelessWidget {
  ManageServiceTypesScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red)),
        title: Text('Nuevo Tipo de Servicio', style: TextStyle(color: context.textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ej. Limpieza de inyectores',
            hintStyle: TextStyle(color: context.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AppController>().addServiceType(controller.text);
              }
              Navigator.pop(ctx);
            },
            child: Text('Agregar', style: TextStyle(color: context.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = context.watch<AppController>().serviceTypes;
    final defaults = [
      'Cambio de Aceite',
      'Llantas',
      'Frenos',
      'Transmisión',
      'Suspensión',
      'Filtros',
      'Bujías',
      'Otro'
    ];

    return Scaffold(
      backgroundColor: context.bg1,
      appBar: AppBar(
        backgroundColor: context.bg1,
        title: Text('Tipos de Servicio', style: TextStyle(color: context.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.bg2, context.bg1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: types.length,
          itemBuilder: (context, index) {
            final t = types[index];
            final isDefault = defaults.contains(t);

            return Card(
              color: context.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: context.borderColor),
              ),
              child: ListTile(
                title: Text(t, style: TextStyle(color: context.textPrimary)),
                trailing: isDefault
                    ? Icon(Icons.lock_outline, color: context.dividerColor)
                    : IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          context.read<AppController>().removeServiceType(t);
                        },
                      ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add, color: context.textPrimary),
      ),
    );
  }
}
