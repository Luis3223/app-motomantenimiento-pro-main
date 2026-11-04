import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';
import 'package:motomantenimiento_pro/ui/features/auth/view_models/password_reset_view_model.dart';

import 'support/fake_auth_repository.dart';

void main() {
  late FakePasswordReset repo;
  late PasswordResetViewModel vm;

  setUp(() {
    repo = FakePasswordReset();
    vm = PasswordResetViewModel(repo);
  });

  Future<void> reachCodeStep() => vm.requestCode('luis@gmail.com');

  group('pedir el código', () {
    test('normaliza el correo y pasa al paso del código', () async {
      await vm.requestCode('  Luis@Gmail.com ');

      expect(repo.requested, ['luis@gmail.com']);
      expect(vm.step, PasswordResetStep.code);
      expect(vm.notice?.isError, isFalse);
      expect(vm.notice?.text, contains('luis@gmail.com'));
    });

    test('el mensaje de envío no revela si la cuenta existe', () async {
      await reachCodeStep();

      expect(vm.notice?.text, startsWith('Si luis@gmail.com tiene una cuenta'));
    });

    test('un correo inválido no llega a Supabase', () async {
      await vm.requestCode('luis@');

      expect(repo.requested, isEmpty);
      expect(vm.step, PasswordResetStep.email);
      expect(vm.notice?.isError, isTrue);
    });

    for (final (result, text) in [
      (ResetRequestResult.rateLimited, 'Espera unos minutos'),
      (ResetRequestResult.offline, 'Sin conexión'),
      (ResetRequestResult.failed, 'No se pudo enviar'),
    ]) {
      test('$result queda en el paso del correo con error', () async {
        repo.requestResult = result;

        await reachCodeStep();

        expect(vm.step, PasswordResetStep.email);
        expect(vm.notice?.isError, isTrue);
        expect(vm.notice?.text, contains(text));
        expect(vm.busy, isFalse);
      });
    }

    test('reenviar usa el mismo correo', () async {
      await reachCodeStep();

      await vm.resendCode();

      expect(repo.requested, ['luis@gmail.com', 'luis@gmail.com']);
    });

    test('usar otro correo vuelve al primer paso', () async {
      await reachCodeStep();

      vm.changeEmail();

      expect(vm.step, PasswordResetStep.email);
      expect(vm.notice, isNull);
    });
  });

  group('cambiar la contraseña', () {
    test('con código y contraseñas válidas termina', () async {
      await reachCodeStep();

      final updated = await vm.confirm(
        code: ' 123456 ',
        password: 'nueva123',
        confirmation: 'nueva123',
      );

      expect(repo.confirmed.single, (
        email: 'luis@gmail.com',
        code: '123456',
        password: 'nueva123',
      ));
      expect(updated, isTrue);
      expect(vm.notice?.isError, isFalse);
    });

    for (final (code, password, confirmation, text) in [
      ('12ab', 'nueva123', 'nueva123', 'código numérico'),
      ('123456', '123', '123', 'al menos 6'),
      ('123456', 'nueva123', 'otra1234', 'no coinciden'),
    ]) {
      test('rechaza sin llamar a Supabase: $text', () async {
        await reachCodeStep();

        final updated = await vm.confirm(
          code: code,
          password: password,
          confirmation: confirmation,
        );

        expect(repo.confirmed, isEmpty);
        expect(updated, isFalse);
        expect(vm.notice?.text, contains(text));
      });
    }

    for (final (result, text) in [
      (ResetConfirmResult.invalidCode, 'no es válido o ya venció'),
      (ResetConfirmResult.weakPassword, 'al menos 6'),
      (ResetConfirmResult.samePassword, 'distinta de la anterior'),
      (ResetConfirmResult.offline, 'Sin conexión'),
      (ResetConfirmResult.failed, 'No se pudo cambiar'),
    ]) {
      test('$result muestra un error y no termina', () async {
        await reachCodeStep();
        repo.confirmResult = result;

        final updated = await vm.confirm(
          code: '123456',
          password: 'nueva123',
          confirmation: 'nueva123',
        );

        expect(updated, isFalse);
        expect(vm.notice?.isError, isTrue);
        expect(vm.notice?.text, contains(text));
      });
    }
  });
}
