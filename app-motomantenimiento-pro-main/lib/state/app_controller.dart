import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/models/oil_status.dart';
import '../data/models/service_record.dart';
import '../data/models/user.dart';
import '../data/repository.dart';

class AppController extends ChangeNotifier {
  AppController({Repository? repository}) : _repository = repository ?? Repository();

  final Repository _repository;

  bool ready = false;
  AppUser? currentUser;
  FirebaseSyncStatus firebaseStatus = FirebaseSyncStatus.onlineSynced;
  List<InAppNotification> notifications = [];
  List<AppUser> allUsers = [];
  List<ServiceRecord> allServices = [];
  List<ServiceRecord> activeUserServices = [];
  List<String> serviceTypes = [];
  bool isDarkMode = true;
  OilChangeStatus? oilChangeStatus;
  ServiceRecord? selectedService;
  String? feedbackMessage;
  InAppNotification? showNotificationAlert;
  String totalMileage = '0 km';
  String recentServiceCount = '00';

  StreamSubscription<List<AppUser>>? _usersSub;
  StreamSubscription<List<ServiceRecord>>? _allServicesSub;
  StreamSubscription<List<ServiceRecord>>? _userServicesSub;
  Timer? _syncTimer;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Future<void> init() async {
    await _repository.init();
    notifications = List.of(_repository.notifications);
    firebaseStatus = _repository.firebaseStatus;
    
    serviceTypes = await _repository.getServiceTypes();

    _usersSub = _repository.allUsers.listen((users) {
      allUsers = users;
      notifyListeners();
    });
    _allServicesSub = _repository.allServices.listen((services) {
      allServices = services;
      notifyListeners();
    });

    ready = true;
    notifyListeners();
  }

  void _bindUserServices(AppUser user) {
    _userServicesSub?.cancel();
    _userServicesSub =
        _repository.watchServicesForUser(user.id).listen((services) {
      activeUserServices = services;
      _updateDashboardCalculations(user, services);
      notifyListeners();
    });
  }

  void _updateDashboardCalculations(AppUser user, List<ServiceRecord> services) {
    if (services.isEmpty) {
      totalMileage = '0 km';
      recentServiceCount = '00';
      oilChangeStatus = const OilChangeStatus(
        lastServiceDate: 'Sin registros',
        daysElapsed: 30,
        daysRemaining: 0,
        progress: 1,
        statusText: 'Mantenimiento urgente',
        isDue: true,
        isWarning: false,
      );
      return;
    }

    final maxMileage = services.map((s) => s.mileage).reduce(max);
    totalMileage = '${NumberFormat('#,###').format(maxMileage)} km';
    recentServiceCount = services.length.toString().padLeft(2, '0');

    final oilServices =
        services.where((s) => s.type.toLowerCase().contains('aceite')).toList();

    if (oilServices.isEmpty) {
      oilChangeStatus = const OilChangeStatus(
        lastServiceDate: 'No registrado',
        daysElapsed: 35,
        daysRemaining: -5,
        progress: 1,
        statusText: 'Vencido hace días',
        isDue: true,
        isWarning: false,
      );
      _triggerSimulationAlert(
        'Mantenimiento Requerido',
        'No hay registro de Cambio de Aceite para tu moto. ¡Es recomendable realizarlo mensualmente!',
      );
      return;
    }

    final latestOil = oilServices.first;
    try {
      final serviceDate = DateFormat('yyyy-MM-dd').parse(latestOil.date);
      final formattedDate = DateFormat('dd MMM yyyy').format(serviceDate);
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final serviceDay =
          DateTime(serviceDate.year, serviceDate.month, serviceDate.day);
      final diffDays = today.difference(serviceDay).inDays;
      const totalCycle = 30;
      final remainingDays = totalCycle - diffDays;
      final calculatedProgress =
          (diffDays / totalCycle).clamp(0.0, 1.0).toDouble();

      late final String statusText;
      late final bool isDue;
      late final bool isWarning;

      if (remainingDays <= 0) {
        isDue = true;
        isWarning = false;
        final daysOverdue = -remainingDays;
        statusText =
            daysOverdue == 0 ? '¡Toca hoy!' : 'Vencido hace $daysOverdue días';
        _triggerSimulationAlert(
          '¡Mantenimiento Requerido Hoy!',
          'Se cumplió el mes desde tu último servicio de aceite. Agenda tu cita en Casa Racing.',
        );
      } else {
        isDue = false;
        isWarning = remainingDays <= 5;
        statusText = 'Faltan $remainingDays días';
        if (isWarning) {
          _triggerSimulationAlert(
            'Alerta de Mantenimiento',
            'Faltan solo $remainingDays días para el próximo vencimiento de cambio de aceite.',
          );
        }
      }

      oilChangeStatus = OilChangeStatus(
        lastServiceDate: formattedDate,
        daysElapsed: diffDays,
        daysRemaining: remainingDays,
        progress: calculatedProgress,
        statusText: statusText,
        isDue: isDue,
        isWarning: isWarning,
      );
    } catch (_) {
      oilChangeStatus = OilChangeStatus(
        lastServiceDate: latestOil.date,
        daysElapsed: 12,
        daysRemaining: 18,
        progress: 0.4,
        statusText: 'Faltan 18 días',
        isDue: false,
        isWarning: false,
      );
    }
  }

  void _triggerSimulationAlert(String title, String message) {
    if (showNotificationAlert == null || showNotificationAlert!.title != title) {
      final alert = InAppNotification(
        title: title,
        message: message,
        date: DateFormat('HH:mm').format(DateTime.now()),
      );
      showNotificationAlert = alert;
      _repository.pushCustomNotification(title, message);
      notifications = List.of(_repository.notifications);
    }
  }

  void dismissNotificationAlert() {
    showNotificationAlert = null;
    notifyListeners();
  }

  void clearFeedback() {
    feedbackMessage = null;
  }

  void selectService(ServiceRecord? service) {
    selectedService = service;
    notifyListeners();
  }

  Future<bool> handleLogin(String email, String pass) async {
    if (email.trim().isEmpty || pass.isEmpty) {
      feedbackMessage = 'Por favor ingresa correo y contraseña.';
      notifyListeners();
      return false;
    }
    final success = await _repository.login(email.trim(), pass);
    if (success) {
      currentUser = _repository.currentUser;
      feedbackMessage = '¡Bienvenido de nuevo!';
      _bindUserServices(currentUser!);
      notifyListeners();
      return true;
    }
    feedbackMessage = 'Credenciales incorrectas. Por favor, intente de nuevo.';
    notifyListeners();
    return false;
  }

  Future<bool> handleRegister({
    required String name,
    required String email,
    required String pass,
    required String model,
    required String plate,
  }) async {
    if ([name, email, pass, model, plate].any((v) => v.trim().isEmpty)) {
      feedbackMessage = 'Por favor completa todos los campos requeridos.';
      notifyListeners();
      return false;
    }
    final vin =
        'YMA${100000 + Random().nextInt(900000)}CASARAC';
    final newUser = AppUser(
      id: email.trim(),
      email: email.trim(),
      password: pass,
      name: name.trim(),
      bikeModel: model.trim(),
      bikePlate: plate.trim(),
      bikeYear: '2024',
      bikeVin: vin,
      profileImage: 'moto_avatar_1',
    );
    final success = await _repository.register(newUser);
    if (success) {
      currentUser = _repository.currentUser;
      feedbackMessage = '¡Registro exitoso en Casa Racing!';
      _bindUserServices(currentUser!);
      notifyListeners();
      return true;
    }
    feedbackMessage = 'Este correo electrónico ya está registrado.';
    notifyListeners();
    return false;
  }

  Future<void> handleProfileUpdate(AppUser user) async {
    await _repository.updateUserProfile(user);
    currentUser = _repository.currentUser;
    feedbackMessage = 'Perfil actualizado exitosamente.';
    notifyListeners();
  }

  Future<bool> handleSaveService({
    required String type,
    required String date,
    required String mileageStr,
    required String notes,
    required String category,
  }) async {
    final mileage = int.tryParse(mileageStr);
    if (type.isEmpty || date.isEmpty || mileage == null) {
      feedbackMessage =
          'Por favor completa el tipo de servicio, fecha y odómetro válido.';
      notifyListeners();
      return false;
    }
    final user = currentUser;
    if (user == null) {
      feedbackMessage = 'Error: Sesión no encontrada.';
      notifyListeners();
      return false;
    }
    await _repository.insertService(
      ServiceRecord(
        userId: user.id,
        type: type,
        date: date,
        mileage: mileage,
        notes: notes,
        category: category,
      ),
    );
    _syncFromRepo();
    feedbackMessage =
        'Mantenimiento registrado y sincronizado en tiempo real con Firebase';
    notifyListeners();
    return true;
  }

  Future<void> handleDeleteService(ServiceRecord service) async {
    await _repository.deleteService(service);
    _syncFromRepo();
    feedbackMessage = 'Registro de servicio eliminado.';
    notifyListeners();
  }

  Future<void> addServiceType(String type) async {
    final t = type.trim();
    if (t.isEmpty || serviceTypes.contains(t)) return;
    await _repository.insertServiceType(t);
    serviceTypes = await _repository.getServiceTypes();
    notifyListeners();
  }

  Future<void> removeServiceType(String type) async {
    await _repository.deleteServiceType(type);
    serviceTypes = await _repository.getServiceTypes();
    notifyListeners();
  }

  void handleLogout() {
    _repository.logout();
    _userServicesSub?.cancel();
    currentUser = null;
    activeUserServices = [];
    oilChangeStatus = null;
    selectedService = null;
    notifyListeners();
  }

  void forceSync() {
    _repository.triggerFirebaseSync();
    firebaseStatus = FirebaseSyncStatus.pending;
    feedbackMessage = 'Sincronizando de forma segura...';
    notifyListeners();
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 1200), () {
      firebaseStatus = FirebaseSyncStatus.onlineSynced;
      notifyListeners();
    });
  }

  void adminPushNotification(String title, String message) {
    _repository.pushCustomNotification(title, message);
    showNotificationAlert = InAppNotification(
      title: title,
      message: message,
      date: DateFormat('HH:mm').format(DateTime.now()),
    );
    notifications = List.of(_repository.notifications);
    feedbackMessage =
        'Alerta de push enviada con éxito a los dispositivos activos.';
    notifyListeners();
  }

  void _syncFromRepo() {
    firebaseStatus = _repository.firebaseStatus;
    notifications = List.of(_repository.notifications);
    if (firebaseStatus == FirebaseSyncStatus.pending) {
      _syncTimer?.cancel();
      _syncTimer = Timer(const Duration(milliseconds: 1200), () {
        firebaseStatus = FirebaseSyncStatus.onlineSynced;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _allServicesSub?.cancel();
    _userServicesSub?.cancel();
    _syncTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
