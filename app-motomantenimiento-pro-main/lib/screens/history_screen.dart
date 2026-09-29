import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/service_record.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'Todos';

  IconData _iconFor(String type) {
    final t = type.toLowerCase();
    if (t.contains('aceite')) return Icons.oil_barrel;
    if (t.contains('cadena')) return Icons.link;
    if (t.contains('llanta')) return Icons.tire_repair;
    if (t.contains('freno')) return Icons.car_crash;
    return Icons.build;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final isAdmin = c.currentUser?.isAdmin ?? false;
    final services = _filter == 'Todos'
        ? c.activeUserServices
        : c.activeUserServices.where((s) => s.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          if (isAdmin)
            TextButton(
              onPressed: () => context.go('/history/admin'),
              child: const Text('Admin', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.strongRed,
        onPressed: () => context.go('/history/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                for (final cat in ['Todos', ...serviceCategories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: _filter == cat,
                      onSelected: (_) => setState(() => _filter = cat),
                      selectedColor: AppColors.strongRed.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: services.isEmpty
                ? const Center(
                    child: Text(
                      'Sin servicios registrados',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.strongRed.withValues(alpha: 0.2),
                            child: Icon(
                              _iconFor(s.type),
                              color: AppColors.strongRed,
                            ),
                          ),
                          title: Text(s.type),
                          subtitle: Text(
                            '${s.date} · ${s.mileage} km · ${s.category}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () =>
                                context.read<AppController>().handleDeleteService(s),
                          ),
                          onTap: () {
                            context.read<AppController>().selectService(s);
                            context.go('/garage/detail');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
