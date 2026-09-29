import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/app.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

void main() {
  testWidgets('Login screen renders', (tester) async {
    final controller = AppController();
    // Skip real DB init for smoke UI test: mark ready without users.
    controller.ready = true;
    await tester.pumpWidget(MotoApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('MotoMantenimiento Pro'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
