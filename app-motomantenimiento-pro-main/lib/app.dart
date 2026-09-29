import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class MotoApp extends StatefulWidget {
  const MotoApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<MotoApp> createState() => _MotoAppState();
}

class _MotoAppState extends State<MotoApp> {
  late final GoRouter _router;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(widget.controller);
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final msg = widget.controller.feedbackMessage;
    if (msg == null) return;
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(msg)));
    widget.controller.clearFeedback();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
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
