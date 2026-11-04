import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';
import 'package:motomantenimiento_pro/router/app_router.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:provider/provider.dart';

import 'fake_auth_repository.dart';

/// Monta la app con el router real, los mismos providers que `MotoApp` y
/// navega a [location]. La superficie ancha evita los desbordes del dashboard
/// con la fuente de test.
Future<GoRouter> pumpRouterApp(
  WidgetTester tester,
  AppController controller, {
  required String location,
  PasswordResetRepository? passwordReset,
}) async {
  await tester.binding.setSurfaceSize(const Size(1600, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = createAppRouter(controller);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        Provider<PasswordResetRepository>.value(
          value: passwordReset ?? FakePasswordReset(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  router.go(location);
  await tester.pumpAndSettle();
  return router;
}

String currentLocation(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();
