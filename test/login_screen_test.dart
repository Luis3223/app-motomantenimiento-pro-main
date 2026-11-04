import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/demo_accounts.dart';
import 'package:motomantenimiento_pro/screens/login_screen.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';
import 'package:motomantenimiento_pro/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'support/fake_repository.dart';

Future<void> _pumpLogin(WidgetTester tester, {Size? surface}) async {
  if (surface != null) {
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  final controller = AppController(repository: FakeRepository());
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: controller,
      child: MaterialApp(theme: buildAppTheme(), home: const LoginScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('el login no muestra credenciales demo', (tester) async {
    await _pumpLogin(tester);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.textContaining('luis@gmail.com'), findsNothing);
    expect(find.textContaining('admin@casaracing.com'), findsNothing);
    expect(find.textContaining(demoPassword), findsNothing);
  });

  testWidgets('sin teclado el login no usa scroll', (tester) async {
    await _pumpLogin(tester, surface: const Size(360, 740));

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('RENDIMIENTO'), findsOneWidget);
  });

  testWidgets('el pie del login queda cerca del borde inferior', (
    tester,
  ) async {
    const surface = Size(412, 915);
    await _pumpLogin(tester, surface: surface);

    final footer = tester.getBottomLeft(find.text('RENDIMIENTO'));
    expect(footer.dy, greaterThan(surface.height * 0.75));
  });
}
