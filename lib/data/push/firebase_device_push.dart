import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'device_push_client.dart';
import 'push_message.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FirebaseDevicePush implements DevicePushClient {
  FirebaseDevicePush({this.messaging});

  final FirebaseMessaging? messaging;
  final _foreground = StreamController<PushMessage>.broadcast();
  final _opened = StreamController<PushMessage>.broadcast();
  final _tokens = StreamController<String>.broadcast();
  PushMessage? _initial;

  FirebaseMessaging get _client => messaging ?? FirebaseMessaging.instance;

  @override
  Stream<PushMessage> get foregroundMessages => _foreground.stream;

  @override
  Stream<PushMessage> get openedMessages => _opened.stream;

  @override
  Stream<String> get tokenRefresh => _tokens.stream;

  @override
  Future<void> start() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _client.requestPermission();
    _initial = _fromRemote(await _client.getInitialMessage());
    FirebaseMessaging.onMessage.listen((message) {
      final parsed = _fromRemote(message);
      if (parsed != null) _foreground.add(parsed);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final parsed = _fromRemote(message);
      if (parsed != null) _opened.add(parsed);
    });
    // `onRegistered` entrega el FID. El envío HTTP v1 usa el token de registro.
    // ignore: deprecated_member_use
    _client.onTokenRefresh.listen(_tokens.add);
  }

  @override
  Future<PushMessage?> takeInitialMessage() async {
    final message = _initial;
    _initial = null;
    return message;
  }

  @override
  Future<String?> currentToken() {
    // El envío HTTP v1 usa `message.token`, no el FID de `onRegistered`.
    // ignore: deprecated_member_use
    return _client.getToken();
  }

  PushMessage? _fromRemote(RemoteMessage? message) {
    if (message == null) return null;
    return pushMessageFrom(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}
