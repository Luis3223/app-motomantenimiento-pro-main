import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/demo_accounts.dart';
import 'package:motomantenimiento_pro/screens/login_screen.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:motomantenimiento_pro/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

void main() {
  testWidgets('el login no muestra credenciales demo', (tester) async {
    final controller = AppController(repository: FakeRepository());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.textContaining('luis@gmail.com'), findsNothing);
    expect(find.textContaining('admin@casaracing.com'), findsNothing);
    expect(find.textContaining(demoPassword), findsNothing);
  });
}
