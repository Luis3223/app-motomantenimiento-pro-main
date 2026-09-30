import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../data/models/service_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();
    final allRecords = c.activeUserServices;

    final records = _selectedFilter == 'Todos'
        ? allRecords
        : allRecords.where((r) => r.category == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: context.bg1,
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.strongRed.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.go('/history/add'),
          backgroundColor: AppColors.strongRed,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: context.isDarkMode
                      ? [const Color(0xFF1A0000), Colors.black]
                      : [Colors.red.shade900, AppColors.strongRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.strongRed.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => context.go('/garage'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Historial',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Registra y consulta todo el mantenimiento de tus motos.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  _buildFilterChip('Todos', Icons.check),
                  const SizedBox(width: 8),
                  _buildFilterChip('Urgente', Icons.warning_amber_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip('Preventivo', Icons.build),
                  const SizedBox(width: 8),
                  _buildFilterChip('Garantía', Icons.shield_outlined),
                ],
              ),
            ),

            // List
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'No hay registros para este filtro',
                        style: TextStyle(color: context.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(context, records[index], c);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.strongRed : context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.strongRed : context.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ServiceRecord record,
    AppController controller,
  ) {
    final isUrgente = record.category == 'Urgente';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.5)),
        boxShadow: context.isDarkMode
            ? [
                BoxShadow(
                  color: AppColors.strongRed.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(-2, -2), // Glow from top left
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            controller.selectService(record);
            context.go('/garage/detail');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Big Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.strongRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconForType(record.type),
                    color: AppColors.strongRed,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.type,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.date,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.speed,
                            size: 12,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${record.mileage} km',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUrgente
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUrgente ? Colors.orange : Colors.green,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 12,
                              color: isUrgente ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record.category,
                              style: TextStyle(
                                color: isUrgente ? Colors.orange : Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.strongRed,
                      ),
                      onPressed: () => controller.handleDeleteService(record),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),
                    Icon(Icons.chevron_right, color: context.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    if (type.toLowerCase().contains('aceite')) return Icons.water_drop_outlined;
    if (type.toLowerCase().contains('cadena')) return Icons.link;
    if (type.toLowerCase().contains('freno')) return Icons.adjust;
    if (type.toLowerCase().contains('llanta')) {
      return Icons.settings_input_component;
    }
    return Icons.build;
  }
}
