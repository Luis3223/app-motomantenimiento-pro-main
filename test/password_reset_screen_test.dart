import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_repository.dart';
import 'support/router_harness.dart';

Future<GoRouter> _pumpReset(
  WidgetTester tester,
  FakePasswordReset reset, {
  AppController? controller,
}) => pumpRouterApp(
  tester,
  controller ?? (AppController(repository: FakeRepository())..ready = true),
  location: '/forgot-password',
  passwordReset: reset,
);

void main() {
  testWidgets('sin sesión se puede abrir la recuperación', (tester) async {
    final router = await _pumpReset(tester, FakePasswordReset());

    expect(currentLocation(router), '/forgot-password');
    expect(find.text('Enviar código'), findsOneWidget);
  });

  testWidgets('el enlace del login abre la recuperación', (tester) async {
    final router = await _pumpReset(tester, FakePasswordReset());
    router.go('/login');
    await tester.pumpAndSettle();

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
    final router = await _pumpReset(
      tester,
      FakePasswordReset(),
      controller: controller,
    );

    expect(currentLocation(router), '/garage');
  });

  testWidgets('pide el código, cambia la contraseña y vuelve al login', (
    tester,
  ) async {
    final reset = FakePasswordReset();
    final router = await _pumpReset(tester, reset);

    await tester.enterText(find.byType(TextField), 'luis@gmail.com');
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();

    expect(reset.requested, ['luis@gmail.com']);
    expect(find.textContaining('te enviamos un código'), findsOneWidget);
    expect(find.text('Reenviar código'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123456');
    await tester.enterText(fields.at(1), 'nueva123');
    await tester.enterText(fields.at(2), 'nueva123');
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(reset.confirmed.single.code, '123456');
    expect(currentLocation(router), '/login');
    expect(
      find.text('Contraseña actualizada. Inicia sesión con la nueva.'),
      findsOneWidget,
    );
  });

  testWidgets('un código vencido muestra el error en pantalla', (tester) async {
    final reset = FakePasswordReset()
      ..confirmResult = ResetConfirmResult.invalidCode;
    final router = await _pumpReset(tester, reset);

    await tester.enterText(find.byType(TextField), 'luis@gmail.com');
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123456');
    await tester.enterText(fields.at(1), 'nueva123');
    await tester.enterText(fields.at(2), 'nueva123');
    await tester.tap(find.text('Cambiar contraseña'));
    await tester.pumpAndSettle();

    expect(currentLocation(router), '/forgot-password');
    expect(find.textContaining('no es válido o ya venció'), findsOneWidget);
  });
}
