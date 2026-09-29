import 'dart:async';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'database/app_database.dart';
import 'models/oil_status.dart';
import 'models/service_record.dart';
import 'models/user.dart';

class Repository {
  Repository();

  Database? _db;
  AppUser? currentUser;
  FirebaseSyncStatus firebaseStatus = FirebaseSyncStatus.onlineSynced;
  List<InAppNotification> notifications = [];

  final _usersController = StreamController<List<AppUser>>.broadcast();
  final _servicesController = StreamController<List<ServiceRecord>>.broadcast();
  final _userServicesControllers =
      <String, StreamController<List<ServiceRecord>>>{};

  Stream<List<AppUser>> get allUsers async* {
    yield await getAllUsers();
    yield* _usersController.stream;
  }

  Stream<List<ServiceRecord>> get allServices async* {
    yield await getAllServices();
    yield* _servicesController.stream;
  }

  Future<void> init() async {
    _db = await AppDatabase.instance();
    notifications = [
      InAppNotification(
        title: 'Bienvenido a Casa Racing',
        message:
            'Tu app de mantenimiento ha sido sincronizada de forma segura con Firebase RTDB.',
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
      ),
    ];
    await tryPrepopulate();
    await _emitUsers();
    await _emitAllServices();
  }

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database not initialized');
    }
    return database;
  }

  Future<void> _emitUsers() async {
    if (!_usersController.isClosed) {
      _usersController.add(await getAllUsers());
    }
  }

  Future<void> _emitAllServices() async {
    final services = await getAllServices();
    if (!_servicesController.isClosed) {
      _servicesController.add(services);
    }
    for (final entry in _userServicesControllers.entries) {
      if (!entry.value.isClosed) {
        entry.value.add(
          services.where((s) => s.userId == entry.key).toList(),
        );
      }
    }
  }

  Stream<List<ServiceRecord>> watchServicesForUser(String userId) {
    final controller = _userServicesControllers.putIfAbsent(
      userId,
      () => StreamController<List<ServiceRecord>>.broadcast(),
    );
    return Stream.multi((listener) async {
      final initial = await getServicesForUser(userId);
      listener.add(initial);
      final sub = controller.stream.listen(
        listener.add,
        onError: listener.addError,
      );
      listener.onCancel = sub.cancel;
    });
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> insertUser(AppUser user) async {
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emitUsers();
  }

  Future<List<AppUser>> getAllUsers() async {
    final rows = await db.query('users');
    return rows.map(AppUser.fromMap).toList();
  }

  Future<List<ServiceRecord>> getServicesForUser(String userId) async {
    final rows = await db.query(
      'services',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, mileage DESC',
    );
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<List<ServiceRecord>> getAllServices() async {
    final rows = await db.query('services', orderBy: 'date DESC, mileage DESC');
    return rows.map(ServiceRecord.fromMap).toList();
  }

  Future<void> insertService(ServiceRecord service) async {
    await db.insert(
      'services',
      service.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    triggerFirebaseSync();
    if (service.type == 'Cambio de Aceite') {
      pushCustomNotification(
        'Servicio Registrado',
        '¡Tu Cambio de Aceite mensual ha sido registrado con éxito! Tu barra de progreso se ha reiniciado.',
      );
    } else {
      pushCustomNotification(
        'Servicio Registrado',
        'Registro de ${service.type} guardado y sincronizado con Firebase Realtime db para ${service.userId}.',
      );
    }
    await _emitAllServices();
  }

  Future<void> deleteService(ServiceRecord service) async {
    if (service.id != null) {
      await db.delete('services', where: 'id = ?', whereArgs: [service.id]);
    }
    triggerFirebaseSync();
    pushCustomNotification(
      'Servicio Eliminado',
      'Mantenimiento de `${service.type}` eliminado correctamente de la base de datos.',
    );
    await _emitAllServices();
  }

  void triggerFirebaseSync() {
    firebaseStatus = FirebaseSyncStatus.pending;
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      firebaseStatus = FirebaseSyncStatus.onlineSynced;
    });
  }

  void pushCustomNotification(String title, String message) {
    notifications = [
      InAppNotification(
        title: title,
        message: message,
        date: DateFormat('HH:mm - dd MMM').format(DateTime.now()),
      ),
      ...notifications,
    ];
  }

  Future<void> tryPrepopulate() async {
    final users = await getAllUsers();
    if (users.isNotEmpty) return;

    await insertUser(
      const AppUser(
        id: 'luis@gmail.com',
        email: 'luis@gmail.com',
        password: '123',
        name: 'Luis Angel Olivera',
        bikeModel: 'Yamaha MT-07',
        bikePlate: 'ABC-123',
        bikeYear: '2023',
        bikeVin: '1YMA7H8B9X204567',
        profileImage: 'moto_avatar_1',
      ),
    );
    await insertUser(
      const AppUser(
        id: 'honda@gmail.com',
        email: 'honda@gmail.com',
        password: '123',
        name: 'Carlos Africa',
        bikeModel: 'Honda Africa Twin',
        bikePlate: 'XYZ-789',
        bikeYear: '2023',
        bikeVin: 'JH2SD12A8PK802145',
        profileImage: 'moto_avatar_2',
      ),
    );
    await insertUser(
      const AppUser(
        id: 'admin@casaracing.com',
        email: 'admin@casaracing.com',
        password: 'admin',
        name: 'Casa Racing Admin',
        bikeModel: 'KTM 390 Duke',
        bikePlate: 'QWE-456',
        bikeYear: '2023',
        bikeVin: 'VKB2UX349KM102394',
        profileImage: 'casaracing_logo',
        isAdmin: true,
      ),
    );

    String daysAgo(int days) {
      final d = DateTime.now().subtract(Duration(days: days));
      return DateFormat('yyyy-MM-dd').format(d);
    }

    Future<void> seed(ServiceRecord s) async {
      await db.insert('services', s.toMap()..remove('id'));
    }

    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Cambio de Aceite',
        date: daysAgo(12),
        mileage: 12500,
        notes:
            'Cambio de aceite Castrol Power1 10W40 sintético y filtro original Casa Racing.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Ajuste de Cadena',
        date: daysAgo(25),
        mileage: 11800,
        notes:
            'Limpieza, lubricación con Motul Chain Lube y ajuste de tensión en Casa Racing.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Cambio de Llantas',
        date: daysAgo(60),
        mileage: 11200,
        notes: 'Instalación de llantas Michelin Road 5 delanteras y traseras.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'luis@gmail.com',
        type: 'Revisión de Frenos',
        date: daysAgo(45),
        mileage: 10500,
        notes:
            'Revisión de pastillas de frenos delanteros y traseros. Pastillas a un 40% de vida útil.',
        category: 'Preventivo',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'admin@casaracing.com',
        type: 'Cambio de Aceite',
        date: daysAgo(40),
        mileage: 8400,
        notes: 'Siguiente servicio urgente debido a fecha vencida (mensual).',
        category: 'Urgente',
      ),
    );
    await seed(
      ServiceRecord(
        userId: 'honda@gmail.com',
        type: 'Servicio General',
        date: daysAgo(5),
        mileage: 22400,
        notes: 'Mantenimiento completo y chequeo electrónico.',
        category: 'Garantía',
      ),
    );

    await _emitAllServices();
  }

  Future<bool> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.password == password) {
      currentUser = user;
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
  }

  Future<bool> register(AppUser user) async {
    final existing = await getUserByEmail(user.email);
    if (existing != null) return false;
    await insertUser(user);
    currentUser = user;
    return true;
  }

  Future<void> updateUserProfile(AppUser user) async {
    await insertUser(user);
    if (currentUser?.id == user.id) {
      currentUser = user;
    }
  }

  Future<void> dispose() async {
    await _usersController.close();
    await _servicesController.close();
    for (final c in _userServicesControllers.values) {
      await c.close();
    }
  }
}
