import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/service_record.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';

class AddRegistryScreen extends StatefulWidget {
  AddRegistryScreen({super.key});

  @override
  State<AddRegistryScreen> createState() => _AddRegistryScreenState();
}

class _AddRegistryScreenState extends State<AddRegistryScreen> {
  String? _type;
  String _category = 'Preventivo';
  DateTime _date = DateTime.now();
  final _mileage = TextEditingController();
  final _notes = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _mileage.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await context.read<AppController>().handleSaveService(
          type: _type ?? '',
          date: DateFormat('yyyy-MM-dd').format(_date),
          mileageStr: _mileage.text.trim(),
          notes: _notes.text.trim(),
          category: _category,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.go('/garage');
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red),
            filled: true,
            fillColor: context.cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final availableTypes = appController.serviceTypes.isEmpty ? serviceTypes : appController.serviceTypes;
    
    _type ??= availableTypes.first;
    if (!availableTypes.contains(_type)) {
      _type = availableTypes.first;
    }

    return Scaffold(
      backgroundColor: context.bg1,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.bg2, context.bg1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: context.textPrimary, size: 32),
                      onPressed: () => context.go('/history'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nuevo Servicio', style: TextStyle(color: context.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            'Agrega los detalles del mantenimiento.',
                            style: TextStyle(color: context.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Tipo de servicio
                    Text('Tipo de servicio', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _type,
                      dropdownColor: context.cardColor,
                      style: TextStyle(color: context.textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.build, color: Colors.red),
                        filled: true,
                        fillColor: context.cardColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      items: [
                        for (final t in availableTypes)
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    SizedBox(height: 16),

                    // Fecha
                    Text('Fecha', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month, color: Colors.red),
                            SizedBox(width: 12),
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
                    SizedBox(height: 16),

                    // Kilometraje
                    _buildTextField(
                      label: 'Kilometraje',
                      controller: _mileage,
                      icon: Icons.speed,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),

                    // Notas
                    _buildTextField(
                      label: 'Notas',
                      controller: _notes,
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                    SizedBox(height: 24),

                    // Categoría
                    Text('Categoría del servicio', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        for (final cat in serviceCategories)
                          GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: _category == cat ? Colors.red : context.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _category == cat ? Colors.red : context.dividerColor),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_category == cat) Icon(Icons.check, color: context.textPrimary, size: 16),
                                  if (_category == cat) SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      color: _category == cat ? context.textPrimary : context.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: context.dividerColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => context.go('/history'),
                              child: Text('Cancelar', style: TextStyle(color: context.textPrimary, fontSize: 16)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _saving ? null : _save,
                              child: _saving
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: context.textPrimary),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save, color: context.textPrimary),
                                        SizedBox(width: 8),
                                        Text('Guardar', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
