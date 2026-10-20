import '../data/models/service_record.dart';

/// Misma regla de 30 días que el cálculo del garage.
const oilCycleDays = 30;

const oilWarningLeadDays = 5;

/// Próximo vencimiento: fecha del último servicio de aceite más [oilCycleDays].
DateTime? nextOilDueDate(Iterable<ServiceRecord> services) {
  DateTime? latest;
  for (final service in services) {
    if (!service.type.toLowerCase().contains('aceite')) continue;
    final parsed = DateTime.tryParse(service.date);
    if (parsed == null) continue;
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    if (latest == null || day.isAfter(latest)) latest = day;
  }
  if (latest == null) return null;
  return latest.add(const Duration(days: oilCycleDays));
}

enum OilReminderKind { warning, due }

class OilReminder {
  const OilReminder({
    required this.kind,
    required this.title,
    required this.body,
    required this.dedupeKey,
  });

  final OilReminderKind kind;
  final String title;
  final String body;
  final String dedupeKey;

  static const route = '/garage';
}

/// Aviso que inserta el cron: dentro de los 5 días previos, o el día del vencimiento.
OilReminder? planOilReminder({
  required DateTime nextOilDue,
  required DateTime today,
}) {
  final due = DateTime(nextOilDue.year, nextOilDue.month, nextOilDue.day);
  final day = DateTime(today.year, today.month, today.day);
  final days = due.difference(day).inDays;
  final dueKey =
      '${due.year.toString().padLeft(4, '0')}-'
      '${due.month.toString().padLeft(2, '0')}-'
      '${due.day.toString().padLeft(2, '0')}';

  if (days == 0) {
    return OilReminder(
      kind: OilReminderKind.due,
      title: '¡Mantenimiento requerido hoy!',
      body: 'Se cumplió el mes desde tu último servicio de aceite. Agenda tu cita en Casa Racing.',
      dedupeKey: 'oil-due:$dueKey',
    );
  }
  if (days >= 1 && days <= oilWarningLeadDays) {
    final body = days == 1
        ? 'Falta 1 día para el próximo vencimiento de cambio de aceite.'
        : 'Faltan $days días para el próximo vencimiento de cambio de aceite.';
    return OilReminder(
      kind: OilReminderKind.warning,
      title: 'Alerta de mantenimiento',
      body: body,
      dedupeKey: 'oil-warning:$dueKey',
    );
  }
  return null;
}
