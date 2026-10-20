import '../data/models/service_record.dart';

/// Puente que la sesión local avisa sin conocer Supabase ni FCM.
abstract class SessionSync {
  Future<void> linkAccount({required String email, required String password});

  Future<void> onServicesChanged(List<ServiceRecord> services);

  Future<void> signOut();
}
