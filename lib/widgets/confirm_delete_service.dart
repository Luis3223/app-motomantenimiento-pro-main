import 'package:flutter/material.dart';

import '../data/models/service_record.dart';
import '../theme/app_theme.dart';

/// Pide confirmación antes de borrar un servicio. Devuelve `true` si el
/// usuario confirma.
Future<bool> confirmDeleteService(
  BuildContext context,
  ServiceRecord service,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('¿Eliminar servicio?'),
      content: Text(
        'Se eliminará "${service.type}" del ${service.date}. '
        'Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.strongRed),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
