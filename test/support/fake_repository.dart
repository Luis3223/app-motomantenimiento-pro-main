import 'dart:async';

import 'package:motomantenimiento_pro/data/models/oil_status.dart';
import 'package:motomantenimiento_pro/data/models/service_record.dart';
import 'package:motomantenimiento_pro/data/models/user.dart';
import 'package:motomantenimiento_pro/data/repository.dart';

AppUser testUser({
  String email = 'luis@gmail.com',
  String password = '123',
  bool isAdmin = false,
}) => AppUser(
  id: email,
  email: email,
  password: password,
  name: 'Luis',
  bikeModel: 'NKD 125',
  bikePlate: 'ABC12D',
  bikeYear: '2022',
  bikeVin: 'VIN',
  profileImage: '',
  isAdmin: isAdmin,
);

ServiceRecord testService({
  int id = 1,
  String userId = 'luis@gmail.com',
  String type = 'Cambio de Aceite',
  String date = '2026-09-01',
  int mileage = 12000,
  String notes = 'Aceite 20W-50',
  String category = 'Preventivo',
}) => ServiceRecord(
  id: id,
  userId: userId,
  type: type,
  date: date,
  mileage: mileage,
  notes: notes,
  category: category,
);

/// Repositorio en memoria que registra las llamadas recibidas.
class FakeRepository extends Repository {
  FakeRepository({List<AppUser>? users, List<ServiceRecord>? services})
    : users = users ?? [testUser()],
      services = services ?? [];

  final List<AppUser> users;
  final List<ServiceRecord> services;
  final loginCalls = <String>[];
  final deletedServices = <ServiceRecord>[];
  final _servicesEvents = StreamController<List<ServiceRecord>>.broadcast();

  /// Reemite los servicios actuales a los observadores, como hace el
  /// repositorio real tras cada escritura.
  void emitServices() => _servicesEvents.add(List.of(services));

  @override
  Future<void> init() async {}

  @override
  Future<List<String>> getServiceTypes() async => ['Cambio de Aceite'];

  @override
  Stream<List<AppUser>> get allUsers => Stream.value(List.of(users));

  @override
  Stream<List<ServiceRecord>> get allServices =>
      Stream.value(List.of(services));

  @override
  Stream<List<ServiceRecord>> watchServicesForUser(String userId) {
    return Stream.multi((listener) {
      listener.add(services.where((s) => s.userId == userId).toList());
      final sub = _servicesEvents.stream.listen(
        (all) => listener.add(all.where((s) => s.userId == userId).toList()),
      );
      listener.onCancel = sub.cancel;
    });
  }

  @override
  Future<AppUser?> getUserByEmail(String email) async {
    for (final u in users) {
      if (u.email == email) return u;
    }
    return null;
  }

  @override
  Future<bool> login(String email, String password) async {
    loginCalls.add(email);
    final user = await getUserByEmail(email);
    if (user == null || user.password != password) return false;
    currentUser = user;
    return true;
  }

  @override
  Future<bool> register(AppUser user) async {
    if (await getUserByEmail(user.email) != null) return false;
    users.add(user);
    currentUser = user;
    return true;
  }

  @override
  void logout() => currentUser = null;

  @override
  Future<void> insertService(ServiceRecord service) async {
    services.add(service);
    emitServices();
  }

  @override
  Future<void> deleteService(ServiceRecord service) async {
    deletedServices.add(service);
    services.removeWhere((s) => s.id == service.id);
    emitServices();
  }

  @override
  void pushCustomNotification(String title, String message) {
    notifications = [
      InAppNotification(title: title, message: message, date: '00:00'),
      ...notifications,
    ];
  }

  @override
  Future<void> dispose() => _servicesEvents.close();
}
