import 'package:flutter_test/flutter_test.dart';
import 'package:motomantenimiento_pro/data/auth/auth_repository.dart';
import 'package:motomantenimiento_pro/data/sync/sync_engine.dart';
import 'package:motomantenimiento_pro/state/app_controller.dart';

import 'support/fake_repository.dart';

void main() {
  test('un login remoto no consulta la contraseña local', () async {
    final repo = FakeRepository();
    final auth = FakeAuthRepository()
      ..accounts['luis@gmail.com'] = (userId: 'uuid-luis', password: 'secret');
    final controller = AppController(repository: repo, auth: auth);
    await controller.init();

    final ok = await controller.handleLogin('luis@gmail.com', 'secret');

    expect(ok, isTrue);
    expect(repo.loginCalls, isEmpty);
    expect(controller.currentUser?.id, 'uuid-luis');
  });

  test(
    'si Auth no tiene la cuenta, la contraseña local permite crearla',
    () async {
      final repo = FakeRepository();
      final auth = FakeAuthRepository();
      final controller = AppController(repository: repo, auth: auth);
      await controller.init();

      final ok = await controller.handleLogin('luis@gmail.com', '123');

      expect(ok, isTrue);
      expect(repo.loginCalls, ['luis@gmail.com']);
      expect(controller.currentUser?.id, 'user-luis@gmail.com');
      expect(auth.accounts.containsKey('luis@gmail.com'), isTrue);
    },
  );

  test('sin sesión de Auth no restaura la sesión local', () async {
    final repo = FakeRepository()..savedSession = testUser();
    final controller = AppController(
      repository: repo,
      auth: FakeAuthRepository(),
    );

    await controller.init();

    expect(controller.currentUser, isNull);
  });

  test('si el envío falla, el alta avisa que queda pendiente', () async {
    final repo = FakeRepository();
    final controller = AppController(
      repository: repo,
      sync: const _OfflineSync(),
    );
    await controller.init();
    await controller.handleLogin('luis@gmail.com', '123');

    final ok = await controller.handleSaveService(
      type: 'Frenos',
      date: '2026-09-10',
      mileageStr: '13000',
      notes: '',
      category: 'Preventivo',
    );

    expect(ok, isTrue);
    expect(
      controller.feedbackMessage,
      contains('Se enviará cuando haya conexión'),
    );
  });
}

class FakeAuthRepository implements AuthRepository {
  final accounts = <String, ({String userId, String password})>{};
  AuthIdentity? session;

  @override
  Future<AuthIdentity?> currentSession() async => session;

  @override
  Future<AuthOutcome> signIn({
    required String email,
    required String password,
  }) async {
    final account = accounts[email];
    if (account == null || account.password != password) {
      return const AuthFailed();
    }
    session = AuthIdentity(userId: account.userId, email: email);
    return AuthSignedIn(userId: account.userId, email: email);
  }

  @override
  Future<AuthOutcome> signUp({
    required String email,
    required String password,
  }) async {
    if (accounts.containsKey(email)) {
      return const AuthFailed(alreadyRegistered: true);
    }
    final userId = 'user-$email';
    accounts[email] = (userId: userId, password: password);
    session = AuthIdentity(userId: userId, email: email);
    return AuthSignedIn(userId: userId, email: email);
  }

  @override
  Future<void> signOut() async => session = null;
}

class _OfflineSync implements HistorySync {
  const _OfflineSync();

  @override
  Future<bool> flush() async => true;

  @override
  Future<void> pull() async => throw StateError('sin red');
}
