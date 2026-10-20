import 'dart:async';

import '../../domain/oil_reminder.dart';
import '../../domain/session_sync.dart';
import '../models/service_record.dart';
import 'device_push_client.dart';
import 'push_message.dart';
import 'remote_notification_repository.dart';

class PushCoordinator implements SessionSync {
  PushCoordinator({required this.remote, required this.device});

  final RemoteNotificationRepository remote;
  final DevicePushClient device;

  List<ServiceRecord> _services = [];
  void Function(PushMessage message)? _onForeground;
  void Function(String route)? _onOpened;
  PushMessage? _pendingOpen;
  StreamSubscription<PushMessage>? _foregroundSub;
  StreamSubscription<PushMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  Future<void> start() async {
    await device.start();
    _pendingOpen = await device.takeInitialMessage();
    _foregroundSub = device.foregroundMessages.listen((message) {
      _onForeground?.call(message);
    });
    _openedSub = device.openedMessages.listen(_deliverOpen);
    _tokenSub = device.tokenRefresh.listen((_) {
      unawaited(_pushTokenAndOil());
    });
  }

  void attach({
    required void Function(PushMessage message) onForeground,
    required void Function(String route) onOpened,
  }) {
    _onForeground = onForeground;
    _onOpened = onOpened;
    final pending = _pendingOpen;
    if (pending != null) {
      _pendingOpen = null;
      _deliverOpen(pending);
    }
  }

  Future<bool> sendAdminAlert({
    required String title,
    required String body,
  }) async {
    try {
      await remote.sendAdminAlert(title: title, body: body);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> linkAccount({
    required String email,
    required String password,
  }) async {
    try {
      await remote.linkAccount(email: email, password: password);
      await _pushTokenAndOil();
    } catch (_) {
      // La sesión local sigue válida si el enlace de avisos falla.
    }
  }

  @override
  Future<void> onServicesChanged(List<ServiceRecord> services) async {
    _services = services;
    try {
      await _pushTokenAndOil();
    } catch (_) {}
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.signOut();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _tokenSub?.cancel();
  }

  void _deliverOpen(PushMessage message) {
    final handler = _onOpened;
    if (handler == null) {
      _pendingOpen = message;
      return;
    }
    handler(message.route);
  }

  Future<void> _pushTokenAndOil() async {
    if (!await remote.hasSession) return;
    final token = await device.currentToken();
    await remote.saveDevice(
      fcmToken: token,
      nextOilDue: nextOilDueDate(_services),
    );
  }
}
