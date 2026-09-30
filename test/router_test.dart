import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motomantenimiento_pro/data/models/user.dart';
import 'package:motomantenimiento_pro/router/app_router.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

Future<GoRouter> _pumpRouter(WidgetTester tester, AppUser user) async {
  final controller = AppController()
    ..ready = true
    ..currentUser = user;
  final router = createAppRouter(controller);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

void main() {
  testWidgets(
    'un usuario no admin que abre /history/admin termina en /history',
    (tester) async {
      final router = await _pumpRouter(tester, testUser());
      router.go('/history/admin');
      await tester.pumpAndSettle();
      expect(_location(router), '/history');
    },
  );

  testWidgets('un administrador puede abrir /history/admin', (tester) async {
    final router = await _pumpRouter(tester, testUser(isAdmin: true));
    router.go('/history/admin');
    await tester.pumpAndSettle();
    expect(_location(router), '/history/admin');
  });
}
