import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_delete_service.dart';

/// Detalle del servicio seleccionado en el historial
/// (`AppController.selectedService`).
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final service = c.selectedService;

    return Scaffold(
      backgroundColor: context.bg1,
      appBar: AppBar(
        title: Text(
          'Detalle del servicio',
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.bg1,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/history'),
        ),
        actions: [
          if (service != null)
            IconButton(
              tooltip: 'Eliminar servicio',
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.strongRed,
              ),
              onPressed: () async {
                if (!await confirmDeleteService(context, service)) return;
                await c.handleDeleteService(service);
                c.selectService(null);
                if (context.mounted) context.go('/history');
              },
            ),
        ],
      ),
      body: service == null
          ? Center(
              child: Text(
                'No hay ningún servicio seleccionado.',
                style: TextStyle(color: context.textSecondary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _DetailRow(label: 'Servicio', value: service.type),
                _DetailRow(label: 'Fecha', value: service.date),
                _DetailRow(
                  label: 'Kilometraje',
                  value: '${service.mileage} km',
                ),
                _DetailRow(label: 'Categoría', value: service.category),
                _DetailRow(
                  label: 'Notas',
                  value: service.notes.trim().isEmpty
                      ? 'Sin notas'
                      : service.notes,
                ),
              ],
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
