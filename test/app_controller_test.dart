import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

import 'support/fake_repository.dart';

void main() {
  late FakeRepository repo;
  late AppController controller;

  setUp(() async {
    repo = FakeRepository();
    controller = AppController(repository: repo);
    await controller.init();
  });

  group('correo electrónico', () {
    test('el login normaliza mayúsculas y espacios', () async {
      final ok = await controller.handleLogin('  Luis@Gmail.COM ', '123');

      expect(ok, isTrue);
      expect(repo.loginCalls, ['luis@gmail.com']);
    });

    test('el registro rechaza un correo con formato inválido', () async {
      final ok = await controller.handleRegister(
        name: 'Ana',
        email: 'ana-sin-arroba',
        pass: '123',
        model: 'NKD',
        plate: 'XYZ',
      );

      expect(ok, isFalse);
      expect(
        controller.feedbackMessage,
        'Ingresa un correo electrónico válido.',
      );
    });

    test('el registro guarda el correo normalizado', () async {
      final ok = await controller.handleRegister(
        name: 'Ana',
        email: ' Ana@Mail.com ',
        pass: '123',
        model: 'NKD',
        plate: 'XYZ',
      );

      expect(ok, isTrue);
      expect(controller.currentUser?.email, 'ana@mail.com');
    });
  });

  group('alertas de mantenimiento', () {
    setUp(() async {
      // Un servicio que no es de aceite dispara "Mantenimiento Requerido".
      repo = FakeRepository(services: [testService(type: 'Ajuste de cadena')]);
      controller = AppController(repository: repo);
      await controller.init();
    });

    int alertCount() => controller.notifications
        .where((n) => n.title == 'Mantenimiento Requerido')
        .length;

    test('no se repiten con cada emisión del historial', () async {
      await controller.handleLogin('luis@gmail.com', '123');
      await pumpEventQueue();
      expect(alertCount(), 1);

      controller.dismissNotificationAlert();
      repo.emitServices();
      repo.emitServices();
      await pumpEventQueue();

      expect(alertCount(), 1);
      expect(controller.showNotificationAlert, isNull);
    });

    test('se vuelven a mostrar tras cerrar sesión y entrar de nuevo', () async {
      await controller.handleLogin('luis@gmail.com', '123');
      await pumpEventQueue();
      controller.handleLogout();
      await controller.handleLogin('luis@gmail.com', '123');
      await pumpEventQueue();

      expect(alertCount(), 2);
    });
  });
}
