import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class AddRegistryScreen extends StatefulWidget {
  const AddRegistryScreen({super.key});

  @override
  State<AddRegistryScreen> createState() => _AddRegistryScreenState();
}

class _AddRegistryScreenState extends State<AddRegistryScreen> {
  final _mileage = TextEditingController();
  final _notes = TextEditingController();
  
  String? _type;
  String _category = 'Preventivo';
  DateTime _date = DateTime.now();
  bool _saving = false;

  final serviceCategories = ['Preventivo', 'Urgente', 'Garantía'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<AppController>();
      if (c.serviceTypes.isNotEmpty) {
        setState(() => _type = c.serviceTypes.first);
      }
    });
  }

  @override
  void dispose() {
    _mileage.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.strongRed,
              onPrimary: Colors.white,
              surface: context.cardColor,
              onSurface: context.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() => _date = d);
    }
  }

  void _save() async {
    if (_mileage.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el kilometraje', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);
    
    final c = context.read<AppController>();
    await c.handleSaveService(
      type: _type ?? c.serviceTypes.first,
      date: DateFormat('yyyy-MM-dd').format(_date),
      mileageStr: _mileage.text,
      notes: _notes.text,
      category: _category,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/garage/history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg1,
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
                    onPressed: () => context.go('/garage/history'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nuevo Servicio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Registra el mantenimiento de tu moto.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Tipo de servicio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tipo de servicio', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                      InkWell(
                        onTap: () => _showManageTypesDialog(context),
                        child: Text(
                          'Gestionar tipos',
                          style: TextStyle(color: AppColors.strongRed, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<AppController>(
                    builder: (context, c, child) {
                      final availableTypes = c.serviceTypes;
                      if (availableTypes.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.dividerColor),
                          ),
                          child: const Text('No hay tipos de servicio disponibles.'),
                        );
                      }
                      
                      // Ensure _type is valid
                      if (_type != null && !availableTypes.contains(_type)) {
                        _type = availableTypes.first;
                      }

                      return DropdownButtonFormField<String>(
                        value: _type ?? availableTypes.first,
                        dropdownColor: context.cardColor,
                        style: TextStyle(color: context.textPrimary),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.build, color: AppColors.strongRed),
                          filled: true,
                          fillColor: context.cardColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: context.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.strongRed),
                          ),
                        ),
                        items: [
                          for (final t in availableTypes)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setState(() => _type = v),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha
                  Text('Fecha', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.dividerColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.strongRed),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(_date),
                              style: TextStyle(color: context.textPrimary, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Kilometraje
                  _buildTextField(
                    context,
                    label: 'Kilometraje',
                    controller: _mileage,
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  _buildTextField(
                    context,
                    label: 'Notas',
                    controller: _notes,
                    icon: Icons.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Categoría
                  Text('Categoría del servicio', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      for (final cat in serviceCategories)
                        GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _category == cat ? AppColors.strongRed : context.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _category == cat ? AppColors.strongRed : context.dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_category == cat)
                                  const Icon(Icons.check, color: Colors.white, size: 16),
                                if (_category == cat) const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: _category == cat ? Colors.white : context.textSecondary,
                                    fontWeight: _category == cat ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.textPrimary,
                              side: BorderSide(color: context.dividerColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => context.go('/garage/history'),
                            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.strongRed.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.strongRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.save),
                                      SizedBox(width: 8),
                                      Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.strongRed) : null,
            filled: true,
            fillColor: context.cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.strongRed),
            ),
          ),
        ),
      ],
    );
  }

  void _showManageTypesDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final c = context.watch<AppController>();
            return AlertDialog(
              backgroundColor: context.bg1,
              title: Text('Gestionar tipos', style: TextStyle(color: context.textPrimary)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            style: TextStyle(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Nuevo tipo de servicio',
                              hintStyle: TextStyle(color: context.textSecondary),
                              filled: true,
                              fillColor: context.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: context.dividerColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.strongRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              if (textController.text.trim().isNotEmpty) {
                                c.addServiceType(textController.text.trim());
                                textController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: c.serviceTypes.length,
                        itemBuilder: (ctx, i) {
                          final type = c.serviceTypes[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(type, style: TextStyle(color: context.textPrimary)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.strongRed),
                              onPressed: () => c.removeServiceType(type),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cerrar', style: TextStyle(color: context.textPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
