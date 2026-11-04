import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/auth/password_reset_repository.dart';
import 'package:motomantenimiento_pro/ui/features/auth/view_models/new_password_view_model.dart';
import 'package:motomantenimiento_pro/ui/features/auth/view_models/password_reset_view_model.dart';

import 'support/fake_auth_repository.dart';

void main() {
  late FakePasswordReset repo;

  setUp(() => repo = FakePasswordReset());

  group('pedir el enlace', () {
    late PasswordResetViewModel vm;

    setUp(() => vm = PasswordResetViewModel(repo));

    test('normaliza el correo y avisa sin revelar si existe', () async {
      await vm.requestLink('  Luis@Gmail.com ');

      expect(repo.requested, ['luis@gmail.com']);
      expect(vm.linkSent, isTrue);
      expect(vm.notice?.isError, isFalse);
      expect(vm.notice?.text, startsWith('Si luis@gmail.com tiene una cuenta'));
    });

    test('un correo inválido no llega a Supabase', () async {
      await vm.requestLink('luis@');

      expect(repo.requested, isEmpty);
      expect(vm.linkSent, isFalse);
      expect(vm.notice?.isError, isTrue);
    });

    for (final (result, text) in [
      (ResetRequestResult.rateLimited, 'Espera unos minutos'),
      (ResetRequestResult.offline, 'Sin conexión'),
      (ResetRequestResult.failed, 'No se pudo enviar'),
    ]) {
      test('$result muestra el error', () async {
        repo.requestResult = result;

        await vm.requestLink('luis@gmail.com');

        expect(vm.linkSent, isFalse);
        expect(vm.notice?.isError, isTrue);
        expect(vm.notice?.text, contains(text));
        expect(vm.busy, isFalse);
      });
    }

    test('reenviar usa el mismo correo', () async {
      await vm.requestLink('luis@gmail.com');

      await vm.resendLink();

      expect(repo.requested, ['luis@gmail.com', 'luis@gmail.com']);
    });
  });

  group('contraseña nueva', () {
    late NewPasswordViewModel vm;

    setUp(() => vm = NewPasswordViewModel(repo));

    test('con contraseñas válidas termina', () async {
      final updated = await vm.save(
        password: 'nueva123',
        confirmation: 'nueva123',
      );

      expect(updated, isTrue);
      expect(repo.updatedPasswords, ['nueva123']);
      expect(vm.notice?.isError, isFalse);
    });

    for (final (password, confirmation, text) in [
      ('123', '123', 'al menos 6'),
      ('nueva123', 'otra1234', 'no coinciden'),
    ]) {
      test('rechaza sin llamar a Supabase: $text', () async {
        final updated = await vm.save(
          password: password,
          confirmation: confirmation,
        );

        expect(updated, isFalse);
        expect(repo.updatedPasswords, isEmpty);
        expect(vm.notice?.text, contains(text));
      });
    }

    for (final (result, text) in [
      (PasswordUpdateResult.weakPassword, 'al menos 6'),
      (PasswordUpdateResult.samePassword, 'distinta de la anterior'),
      (PasswordUpdateResult.expired, 'El enlace venció'),
      (PasswordUpdateResult.offline, 'Sin conexión'),
      (PasswordUpdateResult.failed, 'No se pudo cambiar'),
    ]) {
      test('$result muestra un error y no termina', () async {
        repo.updateResult = result;

        final updated = await vm.save(
          password: 'nueva123',
          confirmation: 'nueva123',
        );

        expect(updated, isFalse);
        expect(vm.notice?.isError, isTrue);
        expect(vm.notice?.text, contains(text));
      });
    }

    test('cancelar descarta la sesión del enlace', () async {
      await vm.cancel();

      expect(repo.cancelCalls, 1);
    });
  });
}
