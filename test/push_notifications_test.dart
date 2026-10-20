import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/config.dart';
import 'package:motomantenimiento_pro/data/models/service_record.dart';
import 'package:motomantenimiento_pro/data/push/device_push_client.dart';
import 'package:motomantenimiento_pro/data/push/push_coordinator.dart';
import 'package:motomantenimiento_pro/data/push/push_message.dart';
import 'package:motomantenimiento_pro/data/push/remote_notification_repository.dart';
import 'package:motomantenimiento_pro/domain/oil_reminder.dart';

void main() {
  test('el payload solo lleva la ruta de navegación', () {
    final data = navigationPayload(pushRouteGarage);
    expect(data, {'route': '/garage'});
    expect(data.keys, isNot(contains('mileage')));
    expect(data.keys, isNot(contains('vin')));
    expect(data.keys, isNot(contains('plate')));
    expect(data.keys, isNot(contains('email')));
  });

  test('no marca éxito si el envío del aviso falla', () async {
    final remote = _FakeRemote()..failSend = true;
    final coordinator = PushCoordinator(remote: remote, device: _FakeDevice());
    final ok = await coordinator.sendAdminAlert(title: 'Aviso', body: 'Texto');
    expect(ok, isFalse);
    expect(remote.sends, isEmpty);
  });

  test('el aviso del admin guarda título, mensaje y ruta', () async {
    final remote = _FakeRemote();
    final coordinator = PushCoordinator(remote: remote, device: _FakeDevice());
    final ok = await coordinator.sendAdminAlert(title: 'Aviso', body: 'Texto');
    expect(ok, isTrue);
    expect(remote.sends.single, {
      'title': 'Aviso',
      'body': 'Texto',
      'route': pushRouteHistory,
    });
  });

  test('el recordatorio distingue los 5 días del día de vencimiento', () {
    final due = DateTime(2026, 10, 25);
    final warning = planOilReminder(
      nextOilDue: due,
      today: DateTime(2026, 10, 20),
    );
    final today = planOilReminder(nextOilDue: due, today: due);
    final tooEarly = planOilReminder(
      nextOilDue: due,
      today: DateTime(2026, 10, 19),
    );

    expect(warning?.kind, OilReminderKind.warning);
    expect(warning?.body, contains('5'));
    expect(warning?.dedupeKey, 'oil-warning:2026-10-25');
    expect(today?.kind, OilReminderKind.due);
    expect(today?.title, '¡Mantenimiento requerido hoy!');
    expect(today?.dedupeKey, 'oil-due:2026-10-25');
    expect(tooEarly, isNull);
  });

  test('la próxima fecha de aceite suma 30 días al último servicio', () {
    final due = nextOilDueDate([
      ServiceRecord(
        userId: 'u',
        type: 'Cambio de Aceite',
        date: '2026-10-01',
        mileage: 1000,
        notes: '',
        category: 'Preventivo',
      ),
      ServiceRecord(
        userId: 'u',
        type: 'Frenos',
        date: '2026-10-20',
        mileage: 1200,
        notes: '',
        category: 'Correctivo',
      ),
    ]);
    expect(due, DateTime(2026, 10, 31));
  });
}

class _FakeRemote implements RemoteNotificationRepository {
  bool failSend = false;
  final sends = <Map<String, String>>[];

  @override
  Future<bool> get hasSession async => false;

  @override
  Future<void> linkAccount({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> saveDevice({String? fcmToken, DateTime? nextOilDue}) async {}

  @override
  Future<void> sendAdminAlert({
    required String title,
    required String body,
  }) async {
    if (failSend) throw StateError('supabase');
    final data = navigationPayload(pushRouteHistory);
    sends.add({'title': title, 'body': body, 'route': data['route']!});
  }

  @override
  Future<void> signOut() async {}
}

class _FakeDevice implements DevicePushClient {
  @override
  Stream<PushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushMessage> get openedMessages => const Stream.empty();

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Future<String?> currentToken() async => null;

  @override
  Future<void> start() async {}

  @override
  Future<PushMessage?> takeInitialMessage() async => null;
}
