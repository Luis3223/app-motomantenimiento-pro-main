import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/models/oil_status.dart';
import 'package:motomantenimiento_pro/router/app_router.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

void main() {
  testWidgets('la campana del Dashboard muestra el historial de avisos', (
    tester,
  ) async {
    final controller = AppController(repository: FakeRepository())
      ..ready = true
      ..currentUser = testUser()
      ..notifications = const [
        InAppNotification(
          title: 'Alerta de Mantenimiento',
          message: 'Faltan 3 días para el cambio de aceite.',
          date: '10:00',
        ),
      ];
    final router = createAppRouter(controller)..go('/garage');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notificaciones'));
    await tester.pumpAndSettle();

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Alerta de Mantenimiento'), findsOneWidget);
    expect(
      find.text('Faltan 3 días para el cambio de aceite.'),
      findsOneWidget,
    );
  });
}
