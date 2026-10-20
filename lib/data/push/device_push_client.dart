import 'push_message.dart';

abstract class DevicePushClient {
  Future<void> start();

  Future<PushMessage?> takeInitialMessage();

  Stream<PushMessage> get foregroundMessages;

  Stream<PushMessage> get openedMessages;

  Stream<String> get tokenRefresh;

  Future<String?> currentToken();
}
