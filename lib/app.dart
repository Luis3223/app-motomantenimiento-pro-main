import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'data/push/push_coordinator.dart';
import 'data/push/push_message.dart';
import 'router/app_router.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class MotoApp extends StatefulWidget {
  const MotoApp({super.key, required this.controller, this.push});

  final AppController controller;
  final PushCoordinator? push;

  @override
  State<MotoApp> createState() => _MotoAppState();
}

class _MotoAppState extends State<MotoApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = createAppRouter(widget.controller);
    widget.controller.addListener(_onControllerChanged);
    widget.push?.attach(
      onForeground: _onForegroundPush,
      onOpened: _onPushOpened,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.syncOnResume();
    }
  }

  void _onForegroundPush(PushMessage message) {
    widget.controller.presentIncomingNotification(message.title, message.body);
  }

  void _onPushOpened(String route) {
    if (widget.controller.currentUser == null) return;
    if (route != pushRouteGarage && route != pushRouteHistory) return;
    _router.go(route);
  }

  void _onControllerChanged() {
    final msg = widget.controller.feedbackMessage;
    if (msg == null) return;
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(msg)));
    widget.controller.clearFeedback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final push = widget.push;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.controller),
        if (push != null) Provider<PushCoordinator>.value(value: push),
      ],
      child: MaterialApp.router(
        title: 'MotoMantenimiento Pro',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        scaffoldMessengerKey: _messengerKey,
        routerConfig: _router,
      ),
    );
  }
}
