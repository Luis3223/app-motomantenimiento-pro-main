import 'package:flutter/material.dart';

import 'app.dart';
import 'data/push/firebase_device_push.dart';
import 'data/push/push_coordinator.dart';
import 'data/push/supabase_remote_notifications.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final remote = SupabaseRemoteNotifications();
  await remote.init();
  final push = PushCoordinator(remote: remote, device: FirebaseDevicePush());
  await push.start();
  final controller = AppController(sessionSync: push);
  await controller.init();
  runApp(MotoApp(controller: controller, push: push));
}
