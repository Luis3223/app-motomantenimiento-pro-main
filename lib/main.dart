import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'data/auth/supabase_auth_repository.dart';
import 'data/auth/supabase_password_reset.dart';
import 'data/push/firebase_device_push.dart';
import 'data/push/push_coordinator.dart';
import 'data/push/supabase_remote_notifications.dart';
import 'data/repository.dart';
import 'data/sync/supabase_sync_remote.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF121212),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFE50914),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ocurrió un problema al cargar la vista',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  final remote = SupabaseRemoteNotifications();
  final repo = Repository();
  final push = PushCoordinator(remote: remote, device: FirebaseDevicePush());

  final controller = AppController(
    repository: repo,
    sessionSync: push,
    auth: SupabaseAuthRepository(),
    syncRemote: SupabaseSyncRemote(),
  );

  // Iniciar la UI INMEDIATAMENTE para que Android descarte el splash nativo al instante
  runApp(
    MotoApp(
      controller: controller,
      push: push,
      passwordReset: SupabasePasswordReset(),
    ),
  );

  // Inicialización de servicios con timeout estricto para redes lentas
  unawaited(_bootstrap(controller, remote, repo, push));
}

Future<void> _bootstrap(
  AppController controller,
  SupabaseRemoteNotifications remote,
  Repository repo,
  PushCoordinator push,
) async {
  // SQLite es local y abre en ~10ms. Supabase tiene timeout de 2s para conexiones lentas.
  await Future.wait([
    repo.init().catchError((_) {}),
    remote.init().timeout(const Duration(seconds: 2)).catchError((_) {}),
  ]);

  try {
    await controller.init().timeout(const Duration(seconds: 3));
  } catch (_) {
    controller.markReady();
  }

  unawaited(push.start());
}
