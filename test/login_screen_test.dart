import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/demo_accounts.dart';
import 'package:motomantenimiento_pro/screens/login_screen.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:motomantenimiento_pro/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

Future<void> _pumpLogin(
  WidgetTester tester, {
  required bool showDemoCredentials,
}) async {
  final controller = AppController(repository: FakeRepository());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(
        theme: buildAppTheme(),
        home: LoginScreen(showDemoCredentials: showDemoCredentials),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('el login muestra las cuentas demo cuando se piden', (
    tester,
  ) async {
    await _pumpLogin(tester, showDemoCredentials: true);

    expect(find.text('Demo: luis@gmail.com\n/ $demoPassword'), findsOneWidget);
    expect(
      find.text('Admin: admin@casaracing.com\n/ $demoPassword'),
      findsOneWidget,
    );
  });

  testWidgets('el login de release no filtra credenciales demo', (
    tester,
  ) async {
    await _pumpLogin(tester, showDemoCredentials: false);

    expect(find.text('Demo: luis@gmail.com\n/ $demoPassword'), findsNothing);
    expect(
      find.text('Admin: admin@casaracing.com\n/ $demoPassword'),
      findsNothing,
    );
  });
}
