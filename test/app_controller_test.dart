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

  group('kilometraje al registrar un servicio', () {
    setUp(() async {
      repo = FakeRepository(
        services: [testService(date: '2026-09-01', mileage: 12000)],
      );
      controller = AppController(repository: repo);
      await controller.init();
      await controller.handleLogin('luis@gmail.com', '123');
      await pumpEventQueue();
    });

    Future<bool> save(String km, {String date = '2026-09-10'}) =>
        controller.handleSaveService(
          type: 'Frenos',
          date: date,
          mileageStr: km,
          notes: '',
          category: 'Preventivo',
        );

    test('rechaza valores negativos', () async {
      final ok = await save('-5');

      expect(ok, isFalse);
      expect(repo.services, hasLength(1));
      expect(
        controller.feedbackMessage,
        'El kilometraje no puede ser negativo.',
      );
    });

    test('avisa si es menor que el de un servicio anterior', () async {
      final ok = await save('11000');

      expect(ok, isTrue);
      expect(repo.services, hasLength(2));
      expect(controller.feedbackMessage, contains('menor'));
      expect(controller.feedbackMessage, contains('12,000'));
    });

    test('no avisa si el kilometraje crece con la fecha', () async {
      final ok = await save('12500');

      expect(ok, isTrue);
      expect(controller.feedbackMessage, isNot(contains('menor')));
    });

    test('no avisa por un servicio posterior con más km', () async {
      final ok = await save('11000', date: '2026-08-01');

      expect(ok, isTrue);
      expect(controller.feedbackMessage, isNot(contains('menor')));
    });
  });

  group('datos del ciclo de aceite y del registro', () {
    test('una fecha ilegible muestra "Fecha inválida"', () async {
      repo = FakeRepository(services: [testService(date: 'no-es-fecha')]);
      controller = AppController(repository: repo);
      await controller.init();
      await controller.handleLogin('luis@gmail.com', '123');
      await pumpEventQueue();

      expect(controller.oilChangeStatus?.statusText, 'Fecha inválida');
    });

    test('el registro no inventa año ni VIN', () async {
      await controller.handleRegister(
        name: 'Ana',
        email: 'ana@mail.com',
        pass: '123',
        model: 'NKD',
        plate: 'XYZ',
      );

      expect(controller.currentUser?.bikeYear, '');
      expect(controller.currentUser?.bikeVin, '');
    });

    test('el registro guarda año y VIN opcionales', () async {
      await controller.handleRegister(
        name: 'Ana',
        email: 'ana@mail.com',
        pass: '123',
        model: 'NKD',
        plate: 'XYZ',
        year: ' 2021 ',
        vin: ' jh2sd12a8pk802145 ',
      );

      expect(controller.currentUser?.bikeYear, '2021');
      expect(controller.currentUser?.bikeVin, 'JH2SD12A8PK802145');
    });
  });

  group('sesión persistente', () {
    test('al arrancar restaura al usuario de la sesión guardada', () async {
      repo = FakeRepository()..savedSession = testUser();
      controller = AppController(repository: repo);

      await controller.init();

      expect(controller.currentUser?.email, 'luis@gmail.com');
      expect(controller.ready, isTrue);
    });

    test('sin sesión guardada arranca sin usuario', () async {
      expect(controller.currentUser, isNull);
    });

    test('cerrar sesión limpia el usuario', () async {
      repo = FakeRepository()..savedSession = testUser();
      controller = AppController(repository: repo);
      await controller.init();

      controller.handleLogout();

      expect(controller.currentUser, isNull);
      expect(repo.currentUser, isNull);
    });
  });
}
