import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/service_record.dart';
import '../state/app_controller.dart';

class AddRegistryScreen extends StatefulWidget {
  const AddRegistryScreen({super.key});

  @override
  State<AddRegistryScreen> createState() => _AddRegistryScreenState();
}

class _AddRegistryScreenState extends State<AddRegistryScreen> {
  String _type = serviceTypes.first;
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
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await context.read<AppController>().handleSaveService(
          type: _type,
          date: DateFormat('yyyy-MM-dd').format(_date),
          mileageStr: _mileage.text.trim(),
          notes: _notes.text.trim(),
          category: _category,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) context.go('/garage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo servicio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/history'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Tipo de servicio'),
            items: [
              for (final t in serviceTypes)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fecha'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: _pickDate,
            ),
          ),
          TextField(
            controller: _mileage,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Kilometraje'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final cat in serviceCategories)
                ChoiceChip(
                  label: Text(cat),
                  selected: _category == cat,
                  onSelected: (_) => setState(() => _category = cat),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sincronizar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
