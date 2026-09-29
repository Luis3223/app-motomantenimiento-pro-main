import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/oil_status.dart';
import '../router/app_router.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final user = c.currentUser;
    final oil = c.oilChangeStatus;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF25D366),
        onPressed: openWhatsApp,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: ListView(
        children: [
          Container(
            color: AppColors.strongRed,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Casa Racing MotoPro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: switch (c.firebaseStatus) {
                                FirebaseSyncStatus.onlineSynced => Colors.green,
                                FirebaseSyncStatus.pending => Colors.yellow,
                                FirebaseSyncStatus.offline => Colors.red,
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            switch (c.firebaseStatus) {
                              FirebaseSyncStatus.onlineSynced =>
                                'Firebase RTDB: Sincronizado',
                              FirebaseSyncStatus.pending =>
                                'Firebase RTDB: Conectando...',
                              FirebaseSyncStatus.offline =>
                                'Firebase RTDB: Desconectado',
                            },
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (user != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Hola, ${user.name}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<AppController>().forceSync(),
                  icon: const Icon(Icons.sync, color: Colors.white),
                ),
              ],
            ),
          ),
          if (oil != null && (oil.isDue || oil.isWarning))
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: oil.isDue
                    ? AppColors.strongRed.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: oil.isDue ? AppColors.strongRed : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: oil.isDue ? AppColors.strongRed : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      oil.isDue
                          ? '¡Aceite vencido! ${oil.statusText}'
                          : 'Aviso: ${oil.statusText}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ciclo de aceite (30 días)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Último servicio: ${oil?.lastServiceDate ?? '—'}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: oil?.progress ?? 0,
                        minHeight: 10,
                        backgroundColor: AppColors.borderGrey,
                        color: (oil?.isDue ?? false)
                            ? AppColors.strongRed
                            : (oil?.isWarning ?? false)
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      oil?.statusText ?? 'Sin datos',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Odómetro',
                    value: c.totalMileage,
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Servicios',
                    value: c.recentServiceCount,
                    icon: Icons.build_circle_outlined,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/garage/detail'),
              icon: const Icon(Icons.info_outline),
              label: const Text('Ver Detalles Técnicos'),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: openStore,
                    icon: const Icon(Icons.storefront),
                    label: const Text('Tienda'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: openWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.lightbulb_outline, color: AppColors.strongRed),
                title: Text('Tip Casa Racing'),
                subtitle: Text(
                  'Cambia el aceite cada 30 días o según el manual del fabricante. Agenda en Casa Racing.',
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.strongRed),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
