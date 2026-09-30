import 'package:flutter/material.dart';

import '../data/models/oil_status.dart';
import '../theme/app_theme.dart';

/// Abre el historial de avisos in-app (el más reciente primero).
Future<void> showNotificationsSheet(
  BuildContext context,
  List<InAppNotification> notifications,
) {
  return showModalBottomSheet<void>(
    context: context,
    // Los colores del tema hacen `watch` del provider: se resuelven dentro del
    // builder, no en el manejador del toque que abre el sheet.
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => DecoratedBox(
      decoration: BoxDecoration(
        color: sheetContext.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Notificaciones',
                  style: TextStyle(
                    color: sheetContext.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No tienes notificaciones.',
                    style: TextStyle(color: sheetContext.textSecondary),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: sheetContext.dividerColor, height: 1),
                    itemBuilder: (_, index) {
                      final n = notifications[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.strongRed,
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            color: sheetContext.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          n.message,
                          style: TextStyle(color: sheetContext.textSecondary),
                        ),
                        trailing: Text(
                          n.date,
                          style: TextStyle(
                            color: sheetContext.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
