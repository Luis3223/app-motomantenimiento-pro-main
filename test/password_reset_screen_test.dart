import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motomantenimiento_pro/app.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_repository.dart';
import 'support/router_harness.dart';

Future<GoRouter> _pumpAt(
  WidgetTester tester,
  String location,
  FakePasswordReset reset, {
  AppController? controller,
}) => pumpRouterApp(
  tester,
  controller ?? (AppController(repository: FakeRepository())..ready = true),
  location: location,
  passwordReset: reset,
);

Future<void> _pumpMotoApp(
  WidgetTester tester,
  AppController controller,
  FakePasswordReset reset,
) async {
  await tester.binding.setSurfaceSize(const Size(1600, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MotoApp(controller: controller, passwordReset: reset),
  );
  // Sin `ready` se ve el splash, que anima sin fin: no se puede asentar.
  if (controller.ready) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  group('pedir el enlace', () {
    testWidgets('sin sesión se puede abrir la recuperación', (tester) async {
      final router = await _pumpAt(
        tester,
        '/forgot-password',
        FakePasswordReset(),
      );

      expect(currentLocation(router), '/forgot-password');
      expect(find.text('Enviar enlace'), findsOneWidget);
    });

    testWidgets('el enlace del login abre la recuperación', (tester) async {
      final router = await _pumpAt(tester, '/login', FakePasswordReset());

      expect(find.text('Continuar con Google'), findsOneWidget);
      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();

      expect(currentLocation(router), '/forgot-password');
    });

    testWidgets('con sesión iniciada la recuperación lleva al garage', (
      tester,
    ) async {
      final controller = AppController(repository: FakeRepository())
        ..ready = true
        ..currentUser = testUser();
      final router = await _pumpAt(
        tester,
        '/forgot-password',
        FakePasswordReset(),
        controller: controller,
      );

      expect(currentLocation(router), '/garage');
    });

    testWidgets('enviar muestra el aviso y permite reenviar', (tester) async {
      final reset = FakePasswordReset();
      await _pumpAt(tester, '/forgot-password', reset);

      await tester.enterText(find.byType(TextField), 'luis@gmail.com');
      await tester.tap(find.text('Enviar enlace'));
      await tester.pumpAndSettle();

      expect(reset.requested, ['luis@gmail.com']);
      expect(find.textContaining('te enviamos un enlace'), findsOneWidget);
      await tester.tap(find.text('Reenviar enlace'));
      await tester.pumpAndSettle();
      expect(reset.requested, hasLength(2));
    });
  });

  group('contraseña nueva', () {
    testWidgets('cambia la contraseña y vuelve al login', (tester) async {
      final reset = FakePasswordReset();
      final router = await _pumpAt(tester, '/reset-password', reset);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'nueva123');
      await tester.enterText(fields.at(1), 'nueva123');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pumpAndSettle();

      expect(reset.updatedPasswords, ['nueva123']);
      expect(currentLocation(router), '/login');
      expect(
        find.text('Contraseña actualizada. Inicia sesión con la nueva.'),
        findsOneWidget,
      );
    });

    testWidgets('volver descarta la sesión del enlace', (tester) async {
      final reset = FakePasswordReset();
      final router = await _pumpAt(tester, '/reset-password', reset);

      await tester.tap(find.byTooltip('Volver al inicio de sesión'));
      await tester.pumpAndSettle();

      expect(reset.cancelCalls, 1);
      expect(currentLocation(router), '/login');
    });

    testWidgets('un enlace vencido muestra el error en pantalla', (
      tester,
    ) async {
      final reset = FakePasswordReset()
        ..updateResult = PasswordUpdateResult.expired;
      final router = await _pumpAt(tester, '/reset-password', reset);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'nueva123');
      await tester.enterText(fields.at(1), 'nueva123');
      await tester.tap(find.text('Cambiar contraseña'));
      await tester.pumpAndSettle();

      expect(currentLocation(router), '/reset-password');
      expect(find.textContaining('El enlace venció'), findsOneWidget);
    });
  });

  group('abrir el enlace del correo', () {
    testWidgets('lleva a la pantalla de contraseña nueva', (tester) async {
      final reset = FakePasswordReset();
      final controller = AppController(repository: FakeRepository())
        ..ready = true;
      await _pumpMotoApp(tester, controller, reset);

      reset.openLink(RecoveryLink.opened);
      await tester.pumpAndSettle();

      expect(find.text('Cambiar contraseña'), findsOneWidget);
    });

    testWidgets('si la app aún arranca, navega al terminar', (tester) async {
      final reset = FakePasswordReset();
      final controller = AppController(repository: FakeRepository());
      await _pumpMotoApp(tester, controller, reset);

      reset.openLink(RecoveryLink.opened);
      await tester.pump();
      controller.markReady();
      await tester.pumpAndSettle();

      expect(find.text('Cambiar contraseña'), findsOneWidget);
    });

    testWidgets('un enlace inválido avisa y pide uno nuevo', (tester) async {
      final reset = FakePasswordReset();
      final controller = AppController(repository: FakeRepository())
        ..ready = true;
      await _pumpMotoApp(tester, controller, reset);

      reset.openLink(RecoveryLink.invalid);
      await tester.pumpAndSettle();

      expect(find.textContaining('no es válido o ya venció'), findsOneWidget);
      expect(find.text('Enviar enlace'), findsOneWidget);
    });
  });
}
