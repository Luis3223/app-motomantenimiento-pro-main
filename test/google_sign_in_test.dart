import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/auth/auth_repository.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_repository.dart';
import 'support/router_harness.dart';

Future<AppController> _controllerWith(
  AuthOutcome? google, {
  FakeRepository? repo,
}) async {
  final auth = google == null
      ? null
      : (FakeAuthRepository()..googleOutcome = google);
  final controller = AppController(
    repository: repo ?? FakeRepository(),
    auth: auth,
  );
  await controller.init();
  return controller;
}

void main() {
  group('handleGoogleSignIn', () {
    test('enlaza la cuenta local con el mismo correo sin duplicarla', () async {
      final repo = FakeRepository(
        services: [testService(userId: 'luis@gmail.com')],
      );
      final controller = await _controllerWith(
        const AuthSignedIn(userId: 'uuid-luis', email: 'Luis@Gmail.com'),
        repo: repo,
      );

      final ok = await controller.handleGoogleSignIn();

      expect(ok, isTrue);
      expect(repo.users, hasLength(1));
      expect(controller.currentUser?.id, 'uuid-luis');
      expect(controller.currentUser?.bikeModel, 'NKD 125');
      expect(repo.services.single.userId, 'uuid-luis');
      expect(controller.feedbackMessage, '¡Bienvenido de nuevo!');
    });

    test('una cuenta nueva entra y pide completar la moto', () async {
      final controller = await _controllerWith(
        const AuthSignedIn(userId: 'uuid-ana', email: 'ana@gmail.com'),
        repo: FakeRepository(users: []),
      );

      final ok = await controller.handleGoogleSignIn();

      expect(ok, isTrue);
      expect(controller.currentUser?.email, 'ana@gmail.com');
      expect(controller.feedbackMessage, contains('Completa los datos'));
    });

    test('cancelar el selector no abre sesión ni muestra aviso', () async {
      final controller = await _controllerWith(const AuthCancelled());

      final ok = await controller.handleGoogleSignIn();

      expect(ok, isFalse);
      expect(controller.currentUser, isNull);
      expect(controller.feedbackMessage, isNull);
    });

    for (final (outcome, text) in [
      (const AuthOffline(), 'Sin conexión'),
      (const AuthUnavailable(), 'no está disponible'),
      (const AuthFailed(), 'No se pudo iniciar sesión con Google'),
    ]) {
      test('${outcome.runtimeType} avisa y no abre sesión', () async {
        final controller = await _controllerWith(outcome);

        final ok = await controller.handleGoogleSignIn();

        expect(ok, isFalse);
        expect(controller.currentUser, isNull);
        expect(controller.feedbackMessage, contains(text));
      });
    }

    test('sin Supabase Auth el acceso con Google no está disponible', () async {
      final controller = await _controllerWith(null);

      final ok = await controller.handleGoogleSignIn();

      expect(ok, isFalse);
      expect(controller.feedbackMessage, contains('no está disponible'));
    });
  });

  testWidgets('el botón de Google del registro entra al garage', (
    tester,
  ) async {
    final auth = FakeAuthRepository()
      ..googleOutcome = const AuthSignedIn(
        userId: 'uuid-luis',
        email: 'luis@gmail.com',
      );
    final controller = AppController(repository: FakeRepository(), auth: auth);
    await controller.init();
    final router = await pumpRouterApp(
      tester,
      controller,
      location: '/register',
    );

    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();

    expect(auth.googleCalls, 1);
    expect(currentLocation(router), '/garage');
  });
}
