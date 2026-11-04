import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../view_models/password_reset_view_model.dart';

/// Estructura común de las pantallas de recuperación: título, texto de ayuda,
/// campos, aviso, botón principal y acciones secundarias.
class ResetFormScaffold extends StatelessWidget {
  const ResetFormScaffold({
    super.key,
    required this.title,
    required this.intro,
    required this.fields,
    required this.vm,
    required this.submitLabel,
    required this.onSubmit,
    required this.onBack,
    this.actions = const [],
  });

  final String title;
  final String intro;
  final List<Widget> fields;
  final ResetFormViewModel vm;
  final String submitLabel;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Volver al inicio de sesión',
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: onBack,
        ),
        title: Text(title, style: TextStyle(color: context.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                intro,
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ...fields,
              if (vm.notice case final notice?) ...[
                const SizedBox(height: 16),
                _NoticeBox(notice: notice),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(55),
                ),
                onPressed: vm.busy ? null : onSubmit,
                child: vm.busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        submitLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.notice});

  final ResetNotice notice;

  @override
  Widget build(BuildContext context) {
    final color = notice.isError ? AppColors.strongRed : context.textPrimary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notice.isError ? AppColors.strongRed : context.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            notice.isError
                ? Icons.error_outline
                : Icons.mark_email_read_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              notice.text,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
