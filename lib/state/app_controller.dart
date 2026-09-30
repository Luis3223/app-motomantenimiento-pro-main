import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/models/oil_status.dart';
import '../data/models/service_record.dart';
import '../data/models/user.dart';
import '../data/repository.dart';

class AppController extends ChangeNotifier {
  AppController({Repository? repository})
    : _repository = repository ?? Repository();

  final Repository _repository;

  bool ready = false;
  AppUser? currentUser;
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

  /// Títulos de alertas ya mostradas en la sesión, para no repetirlas.
  final _shownAlertTitles = <String>{};

  StreamSubscription<List<AppUser>>? _usersSub;
  StreamSubscription<List<ServiceRecord>>? _allServicesSub;
  StreamSubscription<List<ServiceRecord>>? _userServicesSub;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  Future<void> init() async {
    await _repository.init();
    notifications = List.of(_repository.notifications);

    serviceTypes = await _repository.getServiceTypes();

    _usersSub = _repository.allUsers.listen((users) {
      allUsers = users;
      notifyListeners();
    });
    _allServicesSub = _repository.allServices.listen((services) {
      allServices = services;
      notifyListeners();
    });

    if (await _repository.restoreSession() != null) _startSession();

    ready = true;
    notifyListeners();
  }

  void _bindUserServices(AppUser user) {
    _userServicesSub?.cancel();
    _userServicesSub = _repository.watchServicesForUser(user.id).listen((
      services,
    ) {
      activeUserServices = services;
      _updateDashboardCalculations(user, services);
      notifyListeners();
    });
  }

  void _updateDashboardCalculations(
    AppUser user,
    List<ServiceRecord> services,
  ) {
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

    final oilServices = services
        .where((s) => s.type.toLowerCase().contains('aceite'))
        .toList();

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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final serviceDay = DateTime(
        serviceDate.year,
        serviceDate.month,
        serviceDate.day,
      );
      final diffDays = today.difference(serviceDay).inDays;
      const totalCycle = 30;
      final remainingDays = totalCycle - diffDays;
      final calculatedProgress = (diffDays / totalCycle)
          .clamp(0.0, 1.0)
          .toDouble();

      late final String statusText;
      late final bool isDue;
      late final bool isWarning;

      if (remainingDays <= 0) {
        isDue = true;
        isWarning = false;
        final daysOverdue = -remainingDays;
        statusText = daysOverdue == 0
            ? '¡Toca hoy!'
            : 'Vencido hace $daysOverdue días';
        _triggerSimulationAlert(
          '¡Mantenimiento Requerido Hoy!',
          'Se cumplió el mes desde tu último servicio de aceite. Agenda tu cita en Casa Racing.',
        );
      } else {
        isDue = false;
        isWarning = remainingDays <= 5;
        statusText = 'Faltan $remainingDays días';
        if (!isWarning) {
          // El aceite vuelve a estar al día: las alertas pueden repetirse
          // cuando se acerque el siguiente vencimiento.
          _shownAlertTitles.clear();
        } else {
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
    } on FormatException {
      oilChangeStatus = OilChangeStatus(
        lastServiceDate: latestOil.date,
        daysElapsed: 0,
        daysRemaining: 0,
        progress: 0,
        statusText: 'Fecha inválida',
        isDue: false,
        isWarning: false,
      );
    }
  }

  void _triggerSimulationAlert(String title, String message) {
    if (!_shownAlertTitles.add(title)) return;
    showNotificationAlert = InAppNotification(
      title: title,
      message: message,
      date: DateFormat('HH:mm').format(DateTime.now()),
    );
    _repository.pushCustomNotification(title, message);
    notifications = List.of(_repository.notifications);
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _startSession() {
    currentUser = _repository.currentUser;
    _shownAlertTitles.clear();
    _bindUserServices(currentUser!);
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
    final success = await _repository.login(_normalizeEmail(email), pass);
    if (success) {
      _startSession();
      feedbackMessage = '¡Bienvenido de nuevo!';
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
    String year = '',
    String vin = '',
  }) async {
    if ([name, email, pass, model, plate].any((v) => v.trim().isEmpty)) {
      feedbackMessage = 'Por favor completa todos los campos requeridos.';
      notifyListeners();
      return false;
    }
    final normalizedEmail = _normalizeEmail(email);
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      feedbackMessage = 'Ingresa un correo electrónico válido.';
      notifyListeners();
      return false;
    }
    final newUser = AppUser(
      id: normalizedEmail,
      email: normalizedEmail,
      password: pass,
      name: name.trim(),
      bikeModel: model.trim(),
      bikePlate: plate.trim(),
      bikeYear: year.trim(),
      bikeVin: vin.trim().toUpperCase(),
      profileImage: 'moto_avatar_1',
    );
    final success = await _repository.register(newUser);
    if (success) {
      _startSession();
      feedbackMessage = '¡Registro exitoso en Casa Racing!';
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
    final mileage = int.tryParse(mileageStr.trim());
    if (type.isEmpty || date.isEmpty || mileage == null) {
      feedbackMessage =
          'Por favor completa el tipo de servicio, fecha y odómetro válido.';
      notifyListeners();
      return false;
    }
    if (mileage < 0) {
      feedbackMessage = 'El kilometraje no puede ser negativo.';
      notifyListeners();
      return false;
    }
    final user = currentUser;
    if (user == null) {
      feedbackMessage = 'Error: Sesión no encontrada.';
      notifyListeners();
      return false;
    }
    // Las fechas son `yyyy-MM-dd`, así que se comparan como texto.
    final higherEarlier = activeUserServices
        .where((s) => s.date.compareTo(date) < 0 && s.mileage > mileage)
        .map((s) => s.mileage)
        .fold<int?>(null, (a, b) => a == null ? b : max(a, b));
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
    feedbackMessage = higherEarlier == null
        ? 'Mantenimiento registrado en este dispositivo.'
        : 'Mantenimiento registrado, pero el kilometraje es menor que el '
              'de un servicio anterior (${NumberFormat('#,###').format(higherEarlier)} km). '
              'Revisa el dato.';
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
    unawaited(_repository.logout());
    _userServicesSub?.cancel();
    currentUser = null;
    activeUserServices = [];
    oilChangeStatus = null;
    selectedService = null;
    showNotificationAlert = null;
    _shownAlertTitles.clear();
    notifyListeners();
  }

  void adminPushNotification(String title, String message) {
    _repository.pushCustomNotification(title, message);
    showNotificationAlert = InAppNotification(
      title: title,
      message: message,
      date: DateFormat('HH:mm').format(DateTime.now()),
    );
    notifications = List.of(_repository.notifications);
    feedbackMessage = 'Aviso creado en este dispositivo.';
    notifyListeners();
  }

  void _syncFromRepo() {
    notifications = List.of(_repository.notifications);
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _allServicesSub?.cancel();
    _userServicesSub?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
