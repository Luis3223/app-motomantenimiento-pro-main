import '../../config.dart';

class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    required this.route,
  });

  final String title;
  final String body;
  final String route;
}

/// Datos que viajan en el mensaje. Solo la ruta de navegación.
Map<String, String> navigationPayload(String route) {
  if (route != pushRouteGarage && route != pushRouteHistory) {
    throw ArgumentError('Ruta de aviso no permitida');
  }
  return {'route': route};
}

PushMessage? pushMessageFrom({
  required String? title,
  required String? body,
  required Map<String, dynamic> data,
}) {
  final route = data['route'];
  if (route != pushRouteGarage && route != pushRouteHistory) return null;
  return PushMessage(
    title: title ?? '',
    body: body ?? '',
    route: route as String,
  );
}
