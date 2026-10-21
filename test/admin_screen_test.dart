import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/router/app_router.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

void main() {
  testWidgets('el admin muestra el nombre del cliente y no su uuid', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const anaId = '11111111-1111-4111-8111-111111111111';
    final ana = testUser(email: 'ana@mail.com')
        .copyWith(id: anaId, name: 'Ana Ruiz');
    final controller = AppController(repository: FakeRepository())
      ..ready = true
      ..currentUser = testUser(isAdmin: true)
      ..allUsers = [ana, testUser(isAdmin: true)]
      ..allServices = [testService(userId: anaId, type: 'Revisión de Frenos')];
    final router = createAppRouter(controller)..go('/history/admin');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Ruiz'), findsWidgets);
    expect(
      find.textContaining('Ana Ruiz · 2026-09-01 · 12000 km'),
      findsOneWidget,
    );
    expect(find.textContaining(anaId), findsNothing);
  });
}
