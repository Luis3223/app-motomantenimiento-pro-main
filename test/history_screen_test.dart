import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motomantenimiento_pro/router/app_router.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

void main() {
  late FakeRepository repo;
  late AppController controller;
  late GoRouter router;

  Future<void> pumpHistory(WidgetTester tester) async {
    final service = testService(notes: 'Filtro nuevo incluido');
    repo = FakeRepository(services: [service]);
    controller = AppController(repository: repo)
      ..ready = true
      ..currentUser = testUser()
      ..activeUserServices = [service];
    router = createAppRouter(controller)..go('/history');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  testWidgets(
    'tocar un servicio abre su detalle y volver regresa al historial',
    (tester) async {
      await pumpHistory(tester);

      await tester.tap(find.text('Cambio de Aceite'));
      await tester.pumpAndSettle();

      expect(location(), '/history/service');
      expect(find.text('Filtro nuevo incluido'), findsOneWidget);
      expect(find.text('12000 km'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      expect(location(), '/history');
    },
  );

  testWidgets('borrar pide confirmación y cancelar no elimina', (tester) async {
    await pumpHistory(tester);

    await tester.tap(find.byTooltip('Eliminar servicio'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar servicio?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repo.deletedServices, isEmpty);
  });

  testWidgets('confirmar el borrado elimina el servicio', (tester) async {
    await pumpHistory(tester);

    await tester.tap(find.byTooltip('Eliminar servicio'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(repo.deletedServices, hasLength(1));
  });
}
